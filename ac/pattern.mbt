///|
enum Symbol {
  Label(String)
  Child(Int32)
} derive(Eq, Hash, Debug)

///|
type RTLPath = ImmutArray[Symbol] // Automaton path from the pattern root to a labelled leaf, or to the child slot occupied by a metavar.

///|
type TreePattern = ArrayView[(RTLPath, String?)]

///|
pub fn[Loc] build_pattern_from_labelled_tree(
  t : LabelledTree[Loc],
) -> TreePattern {
  let paths = Array()
  fn go(acc : RTLPath, t : LabelledTree[Loc]) -> Unit {
    match t.node {
      Node(label~, children=[]) =>
        paths.push((acc.push(Label(label + "0")), None))
      Node(label~, children~) =>
        children.eachi((i, t) => {
          go(
            acc
            .push(Label(label + children.length().to_string()))
            .push(Child(i)),
            t,
          )
        })
      MetaVar(name) => paths.push((acc, Some(name)))
    }
  }

  go(@immutvector.new(), t)
  return paths
}

///|
pub extend Symbol with Eq::{equal, not_equal}

///|
pub extend Symbol with Hash::{hash, hash_combine}

///|
pub extend Symbol with Debug::{to_repr}
