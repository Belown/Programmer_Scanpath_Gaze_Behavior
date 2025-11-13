import multimatch_gaze as m
import pandas as pd
from ...auxiliary import gen_random_fixations, build_vector, parse_corrected_emip_data

def multimatch(
    exp_a: tuple,
    exp_b: tuple,
    eye_events: pd.DataFrame,
    data_set: str = None
):
    '''
    Compute scanpath similarity by using the library multimatch_gaze
    
    :param: exp_a: Tuple of (experiment_id, trial_id) for first scanpath
    :param: exp_b: Tuple of (experiment_id, trial_id) for second scanpath
    :param: eye_events: Parsed data frame for eye event
    :param: data_set: Specify which data that is used: "corrected" or "original"

    :return: path similarity score
    '''

    if data_set == "corrected":
        parsed_data = parse_corrected_emip_data()
        fix_vec1 = change_name(build_vector(exp_a, parsed_data))

        fix_vec2 = change_name(build_vector(exp_b, parsed_data))

    elif data_set == "original":
        fix_vec1 = change_name(build_vector(exp_a, eye_events))

        fix_vec2 = change_name(build_vector(exp_b, eye_events))
    else:
        raise ValueError("data_set must be either 'corrected' or 'original'")

    random_vec1 = change_name(gen_random_fixations(len(fix_vec1)))

    random_vec2 = change_name(gen_random_fixations(len(fix_vec2)))

    if fix_vec1.size == 0 or fix_vec2.size == 0:
        print("No matching data")
        raise SystemExit("No matching data")

    score = m.docomparison(fix_vec1, fix_vec2, screensize=[1920, 1080])

    original_score_dict = make_dict(score)
    
    base_line_score = m.docomparison(random_vec1, random_vec2, screensize=[1920, 1080])

    base_line_score_dict = make_dict(base_line_score)
    
    final_score_dict = {}
    for name in original_score_dict.keys():
        final_score_dict[name] = original_score_dict[name] - base_line_score_dict[name]

    return {
        "original_score": original_score_dict,
        "base_line_score": base_line_score_dict,
        "final_score": final_score_dict
    }

def make_dict(score):
    '''
    Convert the multimatch score list into a dictionary for better readability.
    
    :param: score: List of multimatch scores.
    
    :return: Dictionary of multimatch scores.
    '''
    score_names = ["Shape", "Length", "Direction", "Position", "Duration"]
    score_dict = {}
    if isinstance(score, list) and len(score) == 1 and isinstance(score[0], list):
        for name, val in zip(score_names, score[0]):
            score_dict[name] = val
    else:
        for name, val in zip(score_names, score):
            score_dict[name] = val
    return score_dict

# Because multimatch_gaze use different column names, we need to change them
def change_name(df):
    '''
    Change the column names of the DataFrame to match the multimatch_gaze requirements.

    :param: df: DataFrame with original column names.

    :return: DataFrame with changed column names.
    '''
    return df.rename(columns={'x0': 'start_x', 'y0': 'start_y'})


