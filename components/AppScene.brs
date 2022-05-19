sub init()
  m.animator = createObject("roSGNode", "FrameAnimator")
  m.decoder = createObject("roSGNode", "GIFDecoder")
  m.decoder.delegate = m.top

  m.top.setFocus(true)
  m.top.backgroundURI = ""
  m.top.backgroundColor = "#292C34"

  setupPosterGrid()
  setupFocusBorder()
  focusItem(0)
end sub

sub setupPosterGrid()
  m.posterGrid = m.top.createChild("Group")

  ' Define layout properties
  m.itemsPerRow = 3
  m.itemsPerColumn = 3
  m.totalItems = m.itemsPerRow * m.itemsPerColumn
  m.itemWidth = 528
  m.itemHeight = 221
  itemSpacing = 25

  ' Create all the posters
  for i = 0 to m.totalItems - 1
    row = Int(i / m.itemsPerRow)
    column = i - (m.itemsPerRow * row)
    x = m.itemWidth * column + itemSpacing * column
    y = m.itemHeight * row + itemSpacing * row

    poster = m.posterGrid.createChild("Poster")
    poster.loadSync = true
    poster.loadDisplayMode = "scaleToFit"
    poster.uri = getGIFUrl(i)
    poster.translation = [x, y]
    poster.width = m.itemWidth
    poster.height = m.itemHeight
  end for

  ' Center in the screen
  totalWidth = m.itemWidth * m.itemsPerRow + itemSpacing * (m.itemsPerRow - 1)
  totalHeight = m.itemHeight * m.itemsPerColumn + itemSpacing * (m.itemsPerColumn - 1)
  m.posterGrid.translation = [1920/2 - totalWidth/2, 1080/2 - totalHeight/2]
end sub

sub setupFocusBorder()
  m.focusBorder = createObject("roSGNode", "Rectangle")
  m.top.insertChild(m.focusBorder, 0)
  m.focusBorder.color = "#ffffff"
  m.focusBorder.width = m.itemWidth + 9
  m.focusBorder.height = m.itemHeight + 9
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
  if key = "left" and not press
    focusItem(m.focusedItem - 1)
  else if key = "up" and not press
    focusItem(m.focusedItem - m.itemsPerRow)
  else if key = "right" and not press
    focusItem(m.focusedItem + 1)
  else if key = "down" and not press
    focusItem(m.focusedItem + m.itemsPerRow)
  end if
  return true
end function

sub focusItem(item as Integer)
  decoderReady = m.decoder.state = "init" or m.decoder.state = "stop"
  if item < 0 or item >= m.totalItems or m.focusedItem = item or not decoderReady
    return
  end if

  ' Re-position focus border
  m.focusedItem = item
  alignNodeToNodeCenter(m.focusBorder, m.posterGrid.getChild(item))

  ' Start decoder
  m.decoder.callFunc("decodeGIF", getGIFUrl(item))

  ' Stop previous poster animation
  m.animator.callFunc("finish")
end sub

sub alignNodeToNodeCenter(node, sibling)
  siblingRect = sibling.sceneBoundingRect()
  node.translation = [siblingRect.x + sibling.width/2 - node.width/2, siblingRect.y + sibling.height/2 - node.height/2]
end sub

function getGIFUrl(posterIndex as Integer) as String
  return "pkg:/images/frozen" + (posterIndex + 1).toStr() + ".gif"
end function

sub gifDecoderDidFinish(frames as Object, fps as Float)
  m.animator.callFunc("start", frames, fps, m.posterGrid.getChild(m.focusedItem))
end sub
