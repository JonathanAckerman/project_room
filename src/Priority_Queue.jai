Priority_Queue :: struct($T: Type, $R: Type) {
    data: [..] T;
    compare: (T,T) -> R;
}

top :: (pq: Priority_Queue($T, $R)) -> T {
    return pq.data[pq.data.count - 1];
}

push :: (pq: *Priority_Queue, elem: $T) {
    array_add(*pq.data, elem);
    quick_sort(pq.data, pq.compare);
}

pop :: (pq: *Priority_Queue($T, $R)) -> T {
    result := top(<<pq);
    pq.data.count -= 1;
    return result;
}

#import "Sort";