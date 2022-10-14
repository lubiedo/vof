module main

import os
import rand
import time

const (
  width  = 30
  height = 30
  esc    = '\x1b'
)

// show prints the universe into the screen
fn show(universe [][]bool, w int, h int)
{
  print('$esc[H')
  mut y := 0
  for y < h {
    mut x := 0
    for x < w {
      print(if universe[y][x] {'$esc[07m  $esc[m'} else{'  '})
      x++
    }
    print('$esc[E')
    y++
  }
  os.flush()
}

// evolve will take care of the universe evolution
fn evolve(mut universe [][]bool, w int, h int)
{
  mut evolution := [][]bool{len: w, init: []bool{len: h}}

  mut y := 0
  for y < h {
    mut x := 0
    for x < w {
      mut new_cell := 0

      for y1 := y-1; y1 <= y+1; y1++ {
        for x1 := x-1; x1 <= x+1; x1++ {
          if universe[(y1+h)%h][(x1+w)%w] { // check if cell is close
            new_cell++
          }
        }
      }

      if universe[y][x] {
        new_cell-- // avoid own if alive
      }
      if new_cell == 3 || // has 3 neighbours so it survives
         (new_cell == 2 && universe[y][x]) // cell is alive and has 2 neighbours
      {
        evolution[y][x] = true
      } else {
        evolution[y][x] = false
      }
      x++
    }
    y++
  }

  universe = evolution.clone()
}

[console]
fn main()
{
  mut w, mut h := 0, 0
  args := os.args.clone()

  if args.len == 3 {
    w = args[1].int()
    h = args[2].int()
  } else {
    w = width
    h = height
  }

  // create universe
  mut universe := [][]bool{len: w, init: []bool{len: h}}
  mut x := 0
  for x < w {
    mut y := 0
    for y < h {
      universe[x][y] = rand.u32() % 8 == 0
      y++
    }
    x++
  }

  // now live!
  for {
    show(universe, w, h)
    evolve(mut universe, w, h)
    time.sleep(time.microsecond * 200000)
  }
}

