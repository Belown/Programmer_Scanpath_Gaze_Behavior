from concurrent.futures import ProcessPoolExecutor, as_completed
import traceback, gc, os, sys
import pandas as pd
from ..path import setup_paths
from ..auxiliary import parse_single_experiment, build_vector

def process_single_experiment(i: int):
    """
    Process one experiment and return (i, length, error).
    If something goes wrong, length is None and error is a traceback string.
    """
    try:
        experiment_id = f"{i}"
        condition = "2"

        eye_event_df, _ = parse_single_experiment(experiment_id)
        vec = build_vector((experiment_id, condition), eye_event_df)
        vec = vec.rename(columns={'x0': 'start_x', 'y0': 'start_y'})
        length = len(vec)

        # free memory
        del eye_event_df
        del vec
        gc.collect()

        return i, length, None

    except Exception:
        err = traceback.format_exc()
        return i, None, err


if __name__ == "__main__":
    paths = setup_paths()
    with ProcessPoolExecutor() as executor:
        futures = {
            executor.submit(process_single_experiment, i): i
            for i in range(1, 217)
        }

        length_list_multi = [None] * 216
        had_error = False

        for fut in as_completed(futures):
            i, length, err = fut.result()

            if err is not None:
                had_error = True
                print(f"Experiment {i} failed:")
                print(err)
            else:
                length_list_multi[i - 1] = length

    if not had_error:
        print("All experiments finished successfully.")
    else:
        print("Some experiments failed; see messages above.")

    # Store length_list for further analysis in csv
    length_df = pd.DataFrame(length_list_multi, columns=['length'])
    output_path = paths["output_path"]
    result_path = os.path.join(output_path, "dataset", "length_list.csv")
    os.makedirs(os.path.dirname(result_path), exist_ok=True)

    length_df.to_csv(result_path, index=False)
    print(f"Result saved to {result_path}")