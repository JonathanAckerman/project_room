// Generalize this
first_empty_index :: (array: [] Hand_Slot) -> int {
    for array {
        if !it.exists return it_index;
    }
    return -1;
}