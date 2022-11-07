fisher_yates_shuffle :: (arr: *[..] $T) {
    // @Note: we have to use the backwards index method for now since jai
    // doesn't include a uniform_random_int in Random or PCG
    for < i: arr.count-1..1 {
        j := random_get_within_bound(cast(u32) (i + 1));
        t : T = (<<arr)[i];
        
        (<<arr)[i] = (<<arr)[j];
        (<<arr)[j] = t;
    }
}