(module
  (import "events" "piecemoved"
    (func $notify_piecemoved (param $fromX i32) (param $fromY i32) (param $toX i32) (param $toY i32))
  )
  (import "events" "piececrowned"
    (func $notify_piececrowned (param $pieceX i32) (param $pieceY i32))
  )

  (memory $mem 1)

  (global $BLACK i32 (i32.const 1))
  (global $WHITE i32 (i32.const 2))
  (global $CROWN i32 (i32.const 4))
  (global $currentTurn (mut i32) (i32.const 0))

  ;; -- Offset calculation
  ;; Calculate index for a two-dimension board
  (func $indexForPosition (param $x i32) (param $y i32) (result i32)
    (i32.add
      (i32.mul
        (i32.const 8)
        (get_local $y)
      )
      (get_local $x)
    )
  )
  ;; Calculate byte offset for a two-dimension board. Offset = ( x + y * 8) * 4
  (func $offsetForPosition (param $x i32) (param $y i32) (result i32)
    (i32.mul
      (i32.const 4)
      (call $indexForPosition (get_local $x) (get_local $y))
    )
  )

  ;; -- Board piece state prediction
  ;; Determine if a piece is black
  (func $isBlack (param $piece i32) (result i32)
    (i32.eq
      (i32.and (get_local $piece) (get_global $BLACK))
      (get_global $BLACK)
    )
  )
  ;; Determine if a piece is white
  (func $isWhite (param $piece i32) (result i32)
    (i32.eq
      (i32.and (get_local $piece) (get_global $WHITE))
      (get_global $WHITE)
    )
  )
  ;; Determine if a piece is crowned
  (func $isCrowned (param $piece i32) (result i32)
    (i32.eq
      (i32.and (get_local $piece) (get_global $CROWN))
      (get_global $CROWN)
    )
  )
  ;; Add a crown to a given piece
  (func $withCrown (param $piece i32) (result i32)
    (i32.or
      (get_local $piece)
      (get_global $CROWN)
    )
  )
  ;; Remove a crown from a given piece
  (func $withoutCrown (param $piece i32) (result i32)
    (i32.and
      (get_local $piece)
      (i32.const 3)
    )
  )

  ;; -- Board piece getter and setter
  ;; Set a piece on the board
  (func $setPiece (param $x i32) (param $y i32) (param $piece i32)
    (i32.store
      (call $offsetForPosition
        (get_local $x)
        (get_local $y)
      )
      (get_local $piece)
    )
  )
  ;; Detect if values are within valid range (inclusive high and low)
  (func $inRange (param $low i32) (param $high i32) (param $value i32) (result i32)
    (i32.and
      (i32.ge_s (get_local $value) (get_local $low))
      (i32.le_s (get_local $value) (get_local $high))
    )
  )
  ;; Get a piece from the board. Out of range causes a trap
  (func $getPiece (param $x i32) (param $y i32) (result i32)
    (if (result i32)
      (block (result i32)
        (i32.and
          (call $inRange (i32.const 0) (i32.const 7) (get_local $x))
          (call $inRange (i32.const 0) (i32.const 7) (get_local $y))
        )
      )
      (then
        (i32.load
          (call $offsetForPosition (get_local $x) (get_local $y))
        )
      )
      (else
        (unreachable)
      )
    )
  )

  ;; -- Turn owner
  ;; Get the current turn owner (white or black)
  (func $getTurnOwner (result i32)
    (get_global $currentTurn)
  )
  ;; Set the turn owner
  (func $setTurnOwner (param $piece i32)
    (set_global $currentTurn (get_local $piece))
  )
  ;; At the end of a turn, switch turn owner to the other player
  (func $toggleTurnOwner
    (if (i32.eq (get_global $currentTurn) (i32.const 1))
      (then (call $setTurnOwner (i32.const 2)))
      (else (call $setTurnOwner (i32.const 1)))
    )
  )
  ;; Determine if it's a player's turn
  (func $isPlayerTurn (param $player i32) (result i32)
    (i32.gt_s
      (i32.and (get_local $player) (call $getTurnOwner))
      (i32.const 0)
    )
  )

  ;; -- Crown a piece
  ;; Should this piece get crowned?
  ;; We crown black pieces in row 0 and white pieces in row 7
  (func $shouldCrown (param $pieceY i32) (param $piece i32) (result i32)
    (i32.or
      (i32.and
        (i32.eq (get_local $pieceY) (i32.const 0))
        (call $isBlack (get_local $piece))
      )
      (i32.and
        (i32.eq (get_local $pieceY) (i32.const 7))
        (call $isWhite (get_local $piece))
      )
    )
  )
  ;; Convert a piece into a crowned piece and invokes a host notifier
  (func $crownPiece (param $x i32) (param $y i32)
    (local $piece i32)
    (set_local $piece (call $getPiece (get_local $x) (get_local $y)))
    (call $setPiece (get_local $x) (get_local $y) (call $withCrown (get_local $piece)))
    (call $notify_piececrowned (get_local $x) (get_local $y))
  )

  ;; -- Moving Players, guard condition
  ;; Determine if a move is valid
  (func $isValidMove (param $fromX i32) (param $fromY i32) (param $toX i32) (param $toY i32) (result i32)
    (local $player i32)
    (local $target i32)

    (set_local $player (call $getPiece (get_local $fromX) (get_local $fromY)))
    (set_local $target (call $getPiece (get_local $toX) (get_local $toY)))

    (if (result i32)
      (block (result i32)
        (i32.and
          (call $validJumpDistance (get_local $fromY) (get_local $toY))
          (i32.and
            (call $isPlayerTurn (get_local $player))
            (i32.eq (get_local $target) (i32.const 0))
          )
        )
      )
      (then
        (i32.const 1)
      )
      (else
        (i32.const 0)
      )
    )
  )
  ;; Calculate abs
  (func $abs (param $a i32) (param $b i32) (result i32)
    (if (result i32)
      (block (result i32)
        (i32.gt_s (get_local $a) (get_local $b))
      )
      (then (i32.sub (get_local $a) (get_local $b)))
      (else (i32.sub (get_local $b) (get_local $a)))
    )
  )
  ;; Ensure travel is for 1 or 2 squares
  (func $validJumpDistance (param $from i32) (param $to i32) (result i32)
    (local $distance i32)
    (set_local $distance (call $abs (get_local $from) (get_local $to)))
    (i32.le_u (get_local $distance) (i32.const 2))
  )

  ;; -- Moving Players, move
  ;; Exported move frunction to be called by the game host
  (func $move (param $fromX i32) (param $fromY i32) (param $toX i32) (param $toY i32) (result i32)
    (if (result i32)
      (block (result i32)
        (call $isValidMove (get_local $fromX) (get_local $fromY) (get_local $toX) (get_local $toY))
      )
      (then
        (call $doMove (get_local $fromX) (get_local $fromY) (get_local $toX) (get_local $toY))
      )
      (else
        (i32.const 0)
      )
    )
  )
  ;; Internal move function, performs actual move post-validation of target.
  ;; TODO:
  ;;   - removing opponent piece during a jump
  ;;   - detecting win condition
  (func $doMove (param $fromX i32) (param $fromY i32) (param $toX i32) (param $toY i32) (result i32)
    (local $curPiece i32)
    (set_local $curPiece (call $getPiece (get_local $fromX) (get_local $fromY)))

    (call $toggleTurnOwner)

    (call $setPiece (get_local $toX) (get_local $toY) (get_local $curPiece))
    (call $setPiece (get_local $fromX) (get_local $fromY) (i32.const 0))

    (if (call $shouldCrown (get_local $toY) (get_local $curPiece))
      (then (call $crownPiece (get_local $toX) (get_local $toY)))
      (call $notify_piecemoved (get_local $fromX) (get_local $fromY) (get_local $toX) (get_local $toY))
    )

    (i32.const 1)
  )

  ;; -- Init Board
  ;; -W-W-W-W
  ;; W-W-W-W-
  ;; -W-W-W-W
  ;; --------
  ;; --------
  ;; B-B-B-B-
  ;; -B-B-B-B
  ;; B-B-B-B-
  (func $initBoard
    (call $setPiece (i32.const 1) (i32.const 0) (get_global $WHITE))
    (call $setPiece (i32.const 3) (i32.const 0) (get_global $WHITE))
    (call $setPiece (i32.const 5) (i32.const 0) (get_global $WHITE))
    (call $setPiece (i32.const 7) (i32.const 0) (get_global $WHITE))

    (call $setPiece (i32.const 0) (i32.const 1) (get_global $WHITE))
    (call $setPiece (i32.const 2) (i32.const 1) (get_global $WHITE))
    (call $setPiece (i32.const 4) (i32.const 1) (get_global $WHITE))
    (call $setPiece (i32.const 6) (i32.const 1) (get_global $WHITE))

    (call $setPiece (i32.const 1) (i32.const 2) (get_global $WHITE))
    (call $setPiece (i32.const 3) (i32.const 2) (get_global $WHITE))
    (call $setPiece (i32.const 5) (i32.const 2) (get_global $WHITE))
    (call $setPiece (i32.const 7) (i32.const 2) (get_global $WHITE))

    (call $setPiece (i32.const 0) (i32.const 5) (get_global $BLACK))
    (call $setPiece (i32.const 2) (i32.const 5) (get_global $BLACK))
    (call $setPiece (i32.const 4) (i32.const 5) (get_global $BLACK))
    (call $setPiece (i32.const 6) (i32.const 5) (get_global $BLACK))

    (call $setPiece (i32.const 1) (i32.const 6) (get_global $BLACK))
    (call $setPiece (i32.const 3) (i32.const 6) (get_global $BLACK))
    (call $setPiece (i32.const 5) (i32.const 6) (get_global $BLACK))
    (call $setPiece (i32.const 7) (i32.const 6) (get_global $BLACK))

    (call $setPiece (i32.const 0) (i32.const 7) (get_global $BLACK))
    (call $setPiece (i32.const 2) (i32.const 7) (get_global $BLACK))
    (call $setPiece (i32.const 4) (i32.const 7) (get_global $BLACK))
    (call $setPiece (i32.const 6) (i32.const 7) (get_global $BLACK))

    (call $setTurnOwner (get_global $BLACK))
  )

  (export "offsetForPosition" (func $offsetForPosition))

  (export "isCrowned" (func $isCrowned))
  (export "isWhite" (func $isWhite))
  (export "isBlack" (func $isBlack))
  (export "withCrown" (func $withCrown))
  (export "withoutCrown" (func $withoutCrown))

  (export "getPiece" (func $getPiece))
  (export "setPiece" (func $setPiece))

  (export "getTurnOwner" (func $getTurnOwner))
  (export "toggleTurnOwner" (func $toggleTurnOwner))
  (export "isPlayerTurn" (func $isPlayerTurn))

  (export "initBoard" (func $initBoard))
  (export "move" (func $move))
  (export "memory" (memory $mem))
)
