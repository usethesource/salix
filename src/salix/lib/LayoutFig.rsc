module salix::lib::LayoutFig


/*

hgap vgap minimum in pixels
hsize vsize minimum  in pixels
hshrink vshrink  (<= 1.0)
hgrow vgrow (> 1.0)
  -> hscale vscale 
  
hresizable vresizable (bool)
halign (0 left, 0.5 center, 1 right) 
  valign (0 top, 0.5 center, 1 bottom)
  
hcat(xs) = grid([xs]);
vcat(xs) = grid([[xs[0]], [xs[1]]...]) 


,
*/