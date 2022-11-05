// Generalize this
first_empty_index :: (array: [] Hand_Slot) -> int {
    for array {
        if !it.exists return it_index;
    }
    return -1;
}

fisher_yates_shuffle :: (arr: [..] $T) -> [..] T {
    // @Note: we have to use the backwards index method for now since jai
    // doesn't include a uniform_random_int in Random or PCG

    result: [..] T;
    for arr array_add(*result, it);

    for < i: result.count-1..1 {
        j := random_get_within_bound(cast(u32) (i + 1));
        t : T = result[i];
        
        result[i] = result[j];
        result[j] = t;
    }

    return result;
}