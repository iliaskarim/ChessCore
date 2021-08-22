# Chess

Chess Swift package

## Example

### Interactive command line program
```swift
print(game)

while game.victor == nil {
  print("\n?", terminator: " ")
  guard let line = readLine() else { continue }
  do {
    try game.move(line)
    print(game)
  } catch {
    print(error.localizedDescription)
  }
}
```

#### Output
```
  White to move

 8 r n b q k b n r
 7 x x x x x x x x
 6                
 5                
 4                
 3                
 2 X X X X X X X X
 1 R N B Q K B N R
   a b c d e f g h

? f3
1. f3

  Black to move

 8 r n b q k b n r
 7 x x x x x x x x
 6                
 5                
 4                
 3           X    
 2 X X X X X   X X
 1 R N B Q K B N R
   a b c d e f g h

? e6
1. f3 e6

  White to move

 8 r n b q k b n r
 7 x x x x   x x x
 6         x      
 5                
 4                
 3           X    
 2 X X X X X   X X
 1 R N B Q K B N R
   a b c d e f g h

? g4
1. f3 e6
2. g4

  Black to move

 8 r n b q k b n r
 7 x x x x   x x x
 6         x      
 5                
 4             X  
 3           X    
 2 X X X X X     X
 1 R N B Q K B N R
   a b c d e f g h

? Qh4
1. f3 e6
2. g4 Qh4#

  Game over
  Black wins.

 8 r n b   k b n r
 7 x x x x   x x x
 6         x      
 5                
 4             X q
 3           X    
 2 X X X X X     X
 1 R N B Q K B N R
   a b c d e f g h
```
