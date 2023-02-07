// Yosys doesn't support non-memory arrays of vectors.
// The following macros make access using plain vectors slightly cleaner.
// Probably a cleaner approach would be to have `va(name,sz,n) define a macro
// `<name>_size that is used in the other macros to get the size, rather than
// needing manual size repetition.  For now, this is good enough, though.
// Also, I'm not sure all preprocessors are up to the task.

// Vector array:
//   wire [N-1:0] array [M-1:0] -> wire [`va(N,M)] array
`define va(sz,n)     (sz)*(n)-1:0
// Array slice select:
//   array[h:l] -> array[M*h:M*l]
`define vas(sz,h,l) ((sz)*((h)+1)-1):(sz)*(l)
// Array elelemnt select:
//   array[i] -> array[`vai(M,i)]
`define vai(sz,e)    `vas(sz,e,e)
// Element slice select:
//   array[i][h:l] -> array[`vais(M,i,h,l)]
`define vais(sz,e,h,l) (sz)*((e)+1)-((sz)-h):(sz)*(e)+(l)
// Element bit select:
//   array[i][j] -> array[M*i+j]
