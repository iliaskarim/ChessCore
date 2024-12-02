# Chess

Chess Swift package

## Example

### Interactive command line program
```swift
var game = Game()
print(game)

while !game.isGameOver {
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
White to move.

 8 r n b q k b n r
 7 p p p p p p p p
 6                
 5                
 4                
 3                
 2 P P P P P P P P
 1 R N B Q K B N R
   a b c d e f g h

? f3
1. f3

Black to move.

 8 r n b q k b n r
 7 p p p p p p p p
 6                
 5                
 4                
 3           P    
 2 P P P P P   P P
 1 R N B Q K B N R
   a b c d e f g h

? e6
1. f3 e6

White to move.

 8 r n b q k b n r
 7 p p p p   p p p
 6         p      
 5                
 4                
 3           P    
 2 P P P P P   P P
 1 R N B Q K B N R
   a b c d e f g h

? g4
1. f3 e6
2. g4

Black to move.

 8 r n b q k b n r
 7 p p p p   p p p
 6         p      
 5                
 4             P  
 3           P    
 2 P P P P P     P
 1 R N B Q K B N R
   a b c d e f g h

? Qh4#
1. f3 e6
2. g4 Qh4#

Black wins.

 8 r n b   k b n r
 7 p p p p   p p p
 6         p      
 5                
 4             P q
 3           P    
 2 P P P P P     P
 1 R N B Q K B N R
   a b c d e f g h
```
