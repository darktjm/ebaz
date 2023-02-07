// Yosys doesn't support non-memory arrays of vectors.
// Vector array:
//   wire [N-1:0] array [M-1:0] -> wire [`va(N,M)] array
`define va(sz,n)     (sz)*(n)-1:0
// Elelemnt select:
//   array[i] -> array[`vai(M,i)]
`define vai(sz,e)    (sz)*((e)+1)-1:(sz)*(e)
// Element slice select:
//   array[i][h:l] -> array[`vais(M,i,h,l)]
`define vais(sz,e,h,l) (sz)*((e)+1)-((sz)-h):(sz)*(e)+(l)
// Element bit select:
//   array[i][j] -> array[M*i+j]
