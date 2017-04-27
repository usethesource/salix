module salix::lib::LayoutFigure
import util::Math;
import salix::SVG;
import salix::HTML;
import salix::App;
import salix::Core;
import salix::lib::Figure;
import salix::lib::Dagre;
import util::Reflective;
import Prelude;

data Figure = root(Figure fig= emptyFigure());
data Figure =  path( list[str] curve, 	str transform="", num scaleX=1.0, num scaleY=1.0	
   			    ,bool fillEvenOdd = true		
   			    ,Figure startMarker=emptyFigure()
   			    ,Figure midMarker=emptyFigure() 
   			    ,Figure endMarker=emptyFigure()	    
   		   );
   		    	
data Event = onclick(Msg m);

value vAlign(Alignment align) {
       if (align == bottomLeft || align == bottomMid || align == bottomRight) return salix::HTML::valign("bottom");
       if (align == centerLeft || align ==centerMid || align ==centerRight)  return salix::HTML::valign("middle");
       if (align == topLeft || align == topMid || align == topRight) return salix::HTML::valign("top");
       return "";
       }
       
value hAlign(Alignment align) {
       if (align == bottomLeft || align == centerLeft || align == topLeft) return salix::HTML::align("left");
       if (align == bottomMid || align == centerMid || align == topMid) return salix::HTML::align("center");
       if (align == bottomRight || align == centerRight || align == topRight) return salix::HTML::align("right");
       return "";   
       }
       
 list[value] fromCommonFigureAttributesToSalix(Figure f) {  
   list[value] r =[];    
   if (!isEmpty(f.fillColor)) r+= salix::SVG::fill(f.fillColor);
   if (!isEmpty(f.lineColor)) r+= salix::SVG::stroke(f.lineColor);
   if (f.lineWidth>=0) r+= salix::SVG::strokeWidth("<f.lineWidth>");
   if (!isEmpty(f.visibility)) r+= salix::SVG::visibility(f.visibility);
   // temporary use value for events
   //if (Attr q := f.event) r+=q;
   return r;
   }
   
list[value] fromFigureAttributesToSalix(f:salix::lib::Figure::circle()) {
   list[value] r =[];
   int lwo = round(f.lineWidth); 
   if (lwo<0) lwo = 0;
   if (f.r<0 && f.width>=0 && f.height>=0) f.r = max(f.width, f.height)/2;
        if (f.r>=0) {r+= salix::SVG::r("<f.r>");
                r+= salix::SVG::cx("<f.at[0]+f.r+lwo/2>");
                r+= salix::SVG::cy("<f.at[1]+f.r+lwo/2>");
                }
   r+=fromCommonFigureAttributesToSalix(f);
   return r; 
   }
   
list[value] fromFigureAttributesToSalix(f:salix::lib::Figure::ellipse()) {
   list[value] r =[];
   int lwo = round(f.lineWidth); 
   if (lwo<0) lwo = 0;
   if (f.rx<0 && f.width>=0) f.rx = f.width/2;
        if (f.ry<0 && f.height>=0) f.ry = f.height/2;
        if (f.rx>=0) {r+= salix::SVG::rx("<f.rx>");
                      r+= salix::SVG::cx("<f.at[0]+f.rx+lwo/2>");
                      }
        if (f.ry>=0) {r+= salix::SVG::ry("<f.ry>");
                      r+= salix::SVG::cy("<f.at[1]+f.ry+lwo/2>");
                      }
   r+=fromCommonFigureAttributesToSalix(f);
   return r; 
   } 
   
 list[value] fromFigureAttributesToSalix(f:salix::lib::Figure::path(list[str] curve),
    list[tuple[Figure, str]] markers) {
   list[value] r =[];
   int lwo = round(f.lineWidth); 
   if (lwo<0) lwo = 0;
   if (f.width>=0) r+= salix::SVG::width("<f.width>"); 
   if (f.height>=0) r+= salix::SVG::height("<f.height>");
   for (tuple[Figure fig, str lab] m<-markers) {
        if (startsWith(m.lab, "startMarker")) r+=salix::SVG::style("marker-start:url(#<m.lab>);");
        else
        if (startsWith(m.lab, "midMarker")) r+=salix::SVG::style("marker-mid:url(#<m.lab>);");
        else
        if (startsWith(m.lab, "endMarker")) r+=salix::SVG::style("marker-end:url(#<m.lab>);");             
        }
   r+=salix::SVG::vectorEffect("non-scaling-stroke");
   r+=salix::SVG::d(intercalate(" ", curve));
   r+=fromCommonFigureAttributesToSalix(f);
   return r; 
   }
   
list[value] fromFigureAttributesToSalix(f:salix::lib::Figure::ngon(),
        list[str] curve) {
   list[value] r =[];
   int lwo = round(f.lineWidth/cos(PI()/f.n)); 
   if (lwo<0) lwo = 0;
   if (f.width>=0) r+= salix::SVG::width("<f.width+0>"); 
   if (f.height>=0) r+= salix::SVG::height("<f.height+0>");
   r+=salix::SVG::vectorEffect("non-scaling-stroke");
   r+=salix::SVG::d(intercalate(" ", curve));
   r+= salix::SVG::x("<lwo/2>"); r+= salix::SVG::y("<lwo/2>");
   r+=fromCommonFigureAttributesToSalix(f);
   return r; 
   }    
       
default list[value] fromFigureAttributesToSalix(Figure f) {
   list[value] r =[];
   int lwo = round(f.lineWidth); 
   if (lwo<0) lwo = 0;
   if (f.width>=0) r+= salix::SVG::width("<f.width>"); 
   if (f.height>=0) r+= salix::SVG::height("<f.height>");
   if (f.rounded[0]>0) r+= salix::SVG::rx("<f.rounded[0]>"); 
   if (f.rounded[1]>0) r+= salix::SVG::ry("<f.rounded[1]>");     
   r+= salix::SVG::x("<lwo/2>"); r+= salix::SVG::y("<lwo/2>");
   r+=fromCommonFigureAttributesToSalix(f);
   return r;
   }
   
list[value] svgSize(Figure f) {
   list[value] r =[];
   int lw = round(f.lineWidth); 
   if (lw<0) lw = 0;
   if (f.width>=0) r+= salix::SVG::width("<f.width+f.at[0]+lw>"); 
   if (f.height>=0) r+= salix::SVG::height("<f.height+f.at[1]+lw>");
   return r;
   }
   
list[value] fromTextPropertiesToSalix(Figure f, bool svg) {
    list[tuple[str, str]] styles=[]; 
    if (!svg) styles+= <"overflow", f.overflow>; 
    int fontSize = (f.fontSize>=0)?f.fontSize:12;
    styles+=<"font-size", "<fontSize>">;
    if (!isEmpty(f.fontStyle)) styles+=<"font-style", f.fontStyle>;
    if (!isEmpty(f.fontFamily)) styles+=<"font-family", f.fontFamily>;
    if (!isEmpty(f.fontWeight)) styles+= <"font-weight", f.fontWeight>;
    if (!isEmpty(f.textDecoration)) styles+=<"text-decoration", f.textDecoration>;
    if (!isEmpty(f.fontColor)) styles+=<(svg?"fill":"color"), f.fontColor>;
    if (svg) {
        if (!isEmpty(f.fontLineColor)) styles+= <"stroke",f.fontLineColor>;
        if (f.fontLineWidth>=0) styles+=<"stroke-width", "<f.fontLineWidth>">;
        styles+=<"text-anchor", "middle">;
        }
    if (f.width>=0) styles+= <"width", "<f.width>">; 
    if (f.height>=0) styles+= <"height", "<f.height>">;
    list[value] r =[salix::HTML::style(styles)];
    if (svg) {
        if (f.width>=0) r+=salix::SVG::x("<f.width/2>");
        if (f.height>=0) r+=salix::SVG::y("<f.height/2+6>");
        }
    return r;
   }
   
list[value] fromTableModelToProperties(Figure f) {
    list[value] r =[];
    list[tuple[str, str]] styles=[];     
        styles += <"border-spacing", "<f.hgap> <f.vgap>">;
        styles+= <"border-collapse", "separate">;
        //if (f.width>=0) styles+= <"width", "<f.width>">; 
        // if (f.height>=0) styles+= <"height", "<f.height>">;
        r+=salix::HTML::style(styles);
        return r;    
   }
   
list[value] fromTdModelToProperties(Figure f, Figure g) {
    list[tuple[str, str]] styles = [<"padding", 
    "<round(g.padding[1])> <round(g.padding[2])> <round(g.padding[3])> <round(g.padding[0])>">];
    if (f.borderWidth>=0) styles += <"border-width", "<f.borderWidth>">;
    if (!isEmpty(f.borderColor)) styles+= <"border-color", "<f.borderColor>">;
    if (!isEmpty(f.borderStyle)) styles+= <"border-style", "<f.borderStyle>">;
    list[value] r =[salix::HTML::style(styles)];
    value q = hAlign(g.cellAlign);
    if (str _:=q) r += hAlign(f.align); else r+=q;
    q = vAlign(g.cellAlign);
    if (str _:=q) r += vAlign(f.align); else r+=q;
    return r;
    }
   
void() innerFig(Figure outer, Figure inner) {
    return (){
       int lwo = (ngon():=outer)? round(outer.lineWidth/cos(PI()/outer.n)): outer.lineWidth;
       if (lwo<0) lwo = 0;
       int lwi = (ngon():=inner)? round(inner.lineWidth/cos(PI()/inner.n)): inner.lineWidth;
       if (lwo<0) lwo = 0; if (lwi<0) lwi = 0;
       int widtho = round(outer.width); int heighto = round(outer.height);
       int widthi = round(inner.width); int heighti = round(inner.height);    
       list[value] svgArgs = [];
       if (widthi>=0) svgArgs+= salix::SVG::width("<widthi+lwi+inner.at[0]>");
       if (heighti>=0) svgArgs+= salix::SVG::height("<heighti+lwi+inner.at[1]>");
       list[value] foreignObjectArgs = [style(<"line-height", "0">)];
       if (widtho>=0) foreignObjectArgs+= salix::SVG::width("<widtho-lwo>");
       if (heighto>=0) foreignObjectArgs+= salix::SVG::height("<heighto-lwo>");
       foreignObjectArgs+= salix::SVG::x("<lwo>"); foreignObjectArgs+= salix::SVG::y("<lwo>");
       list[value] tdArgs = fromTdModelToProperties(outer, inner);
       list[value] tableArgs = foreignObjectArgs; 
       foreignObject(foreignObjectArgs+[(){table(tableArgs+[(){tr((){td(tdArgs+[(){svg(svgArgs+[(){eval(inner);}]);}]);});}]);}]);
       };
    } 
     
void() tableCells(Figure f, list[Figure] g) {
    list[void()] r =[];
    for (Figure h<-g) {
       Figure w= h; // Because of bug in rascal?
       list[value] svgArgs = [];
       int width = round(h.width); int height = round(h.height);
       int lw = round(h.lineWidth);
       if (lw<0) lw = 0;
       if (width>=0) svgArgs+= salix::SVG::width("<width+lw+h.at[0]>");
       if (height>=0) svgArgs+= salix::SVG::height("<height+lw+h.at[1]>");
       list[value] tdArgs = fromTdModelToProperties(f, h); 
       r+= [() {
           salix::HTML::td(tdArgs+[(){svg(svgArgs+[(){eval(w);}]);}]);
        }];
       }
    return () {for  (void() z<-r) z();};
    }
    
void() tableRows(Figure f) {
    list[void()] r =[];
    list[list[Figure]] figArray = [];
    if (grid():=f) figArray = f.figArray;
    else if (vcat():=f) figArray  = [[h]|h<-f.figs];    
    else if (hcat():=f) figArray  = [f.figs];
    for (list[Figure] g<-figArray) {
      list[Figure] w  = g;
        r+= [() {
        salix::HTML::tr(tableCells(f, w));  
        }];
       }
    return () {for (void() z<-r) z();};
    }
    
num getGrowFactor(Figure f, Figure g) {
    if ((salix::lib::Figure::circle():=f||salix::lib::Figure::ellipse():=f)&&box():=g) return sqrt(2);
    return 1;
    }
    
bool hasFigField(Figure f) = root():=f || box():=f || salix::lib::Figure::circle():=f || salix::lib::Figure::ellipse():=f 
       || salix::lib::Figure::ngon():=f;

Figure pullDim(atXY(num x, num y, Figure g)) {
      g.at = <x, y>;
      return pullDim(g);
      }
      
Figure pullDim(Figure f:path(list[str] _)) {
      if (emptyFigure()!:=f.startMarker) f.startMarker = pullDim(f.startMarker);
      if (emptyFigure()!:=f.midMarker) f.midMarker = pullDim(f.midMarker);
      if (emptyFigure()!:=f.endMarker) f.endMarker = pullDim(f.endMarker);
      return f;
      }
      
 Figure pullDim(Figure f:salix::lib::Figure::graph()) {
      if (f.size != <0, 0>) {
          if (f.width<0) f.width = f.size[0];
          if (f.height<0) f.height = f.size[1];
       }
      list[tuple[str, Figure]] r = [];
      for (tuple[str id, Figure fig] d<-f.nodes) {
            r+=[<d.id, pullDim(d.fig)>];
            }
      f.nodes = r;
      return f;
      }

Figure pullDim(Figure f:overlay()) {
    if (f.size != <0, 0>) {
       if (f.width<0) f.width = f.size[0];
       if (f.height<0) f.height = f.size[1];
       }  
    if (isEmpty(f.figs)) return f;
    f.figs = [pullDim(h)|Figure h<-f.figs];
    int maxWidth = round(max([h.width+h.at[0]+(h.lineWidth<0?0:h.lineWidth)|h<-f.figs]));
    int maxHeight = round(max([h.height+h.at[1]+(h.lineWidth<0?0:h.lineWidth)|h<-f.figs]));
    if (f.width<0) f.width = maxWidth;
    if (f.height<0) f.height = maxHeight;
    return f;
    }
      
default Figure pullDim(Figure f) {
     if (f.size != <0, 0>) {
       if (f.width<0) f.width = f.size[0];
       if (f.height<0) f.height = f.size[1];
       }  
     if (f.lineWidth<0)
         f.lineWidth = f.borderWidth;
     if ((salix::lib::Figure::circle():=f || salix::lib::Figure::ngon():=f) && f.width<0 && f.height<0 && f.r>=0) {
            f.width = 2 * round(f.r); f.height = 2 * round(f.r);
        }
     if (salix::lib::Figure::ellipse():=f) {
           if (f.width<0 && f.rx>=0) {
              f.width = 2 * round(f.rx); 
              }
           if (f.height<0 && f.ry>=0) {
              f.height = 2 * round(f.ry); 
              }
           }
     if (hasFigField(f) && emptyFigure()!:=f.fig) {    
        f.fig = pullDim(f.fig);
        Figure g = f.fig;
        int lwo = round((ngon():=f)? f.lineWidth/cos(PI()/f.n): f.lineWidth);
        if (lwo<0) lwo = 0; 
        int lwi = round((ngon():=g)? g.lineWidth/cos(PI()/g.n): g.lineWidth);
        if (lwi<0) lwi = 0;
        if (f.width<0 && g.width>=0) f.width = round(f.grow*getGrowFactor(f, g)*g.width) + lwi+round(g.at[0])+lwo;
        if (f.height<0 && g.height>=0) f.height = round(f.grow*getGrowFactor(f, g)*g.height) + lwi+round(g.at[1])+lwo;
        // To Do the case of a circle
        }
     if (grid():=f || vcat():=f || hcat():=f) {
         list[list[Figure]] z =[];
         int height = 0;
         int lw = round(f.borderWidth);
         if (lw<0) lw = 0;
         int nc  = 0;
         list[list[Figure]] figArray = [];
         if (grid():=f) figArray = f.figArray;
         else if (vcat():=f) figArray= [[h]|h<-f.figs]; 
         else if (hcat():=f) figArray  = [f.figs];
         list[int] maxColWidth = [-1|_<-[0..max([size(g)|g<-figArray])]];
         for (list[Figure] g<- figArray) {
            list[Figure] r = [];
            int h1 = 0;
            int i = 0;   
            for (Figure h<-g)  {
                  int lwi = round(h.lineWidth);
                  if (lwi<0) lwi = 0;
                  Figure v = pullDim(h);
                  int colWidth = v.width>=0?(v.width+lwi+h.padding[0]+h.padding[2]+round(h.at[0])):-1;
                  if (maxColWidth[i]<colWidth) maxColWidth[i] = colWidth;
                  if (h1>=0) if (v.height>=0) h1 = max([h1, v.height+lwi+h.padding[1]+h.padding[3]+round(h.at[1])]);else h1=-1;
                  r += [v]; 
                  i += 1;     
                  }
            nc = max(nc, size(g));
            if (height>=0) if (h1>=0) height+=h1; else height = -1;     
            z+=[r];
            } 
          int width = sum(maxColWidth);  
          if (grid():=f) f.figArray= z;
          else
          if (vcat():=f) f.figs = [head(h)|list[Figure] h<-z];
          else
          if (hcat():=f) f.figs = head(z);
          if (f.width<0) f.width = width+nc*(f.hgap+2*lw)+f.hgap; 
          if (f.height<0) f.height = height+size(z)*(f.vgap+2*lw)+f.vgap;
          }
     return f;
     }
     
 list[list[Figure]] transpose(list[list[Figure]] m) {
     list[list[Figure]] r = [[]|_<-[0..max([size(g)|g<-m])]];
     for (int i<-[0..size(m)]) {
          for (int j<-[0..size(m[i])]) {
             r[j]+=[m[i][j]];
          }
       }
     return r;    
     }
     
 tuple[num, list[list[Figure]]] getHeightMissingCells(int height, int lw, int vgap, list[list[Figure]] figArray) {
     if (height<0) return <-1, []>;
     int nUndefinedRows = 0;
     int definedHeight = 0;
     int sumLw = 0;
     list[list[Figure]] z =[];
     for (list[Figure] g<- figArray) {
         list[Figure] r =[];
         int maxHeight = -1;int maxLw = -1;
         for (Figure h<-g) {
              maxHeight= max(h.height, maxHeight);
              maxLw = max(h.lineWidth, maxLw);
         }
         if (maxHeight>=0) definedHeight= definedHeight+maxHeight;
         if (maxLw>=0) sumLw+=maxLw;
         for (Figure h<-g) {
              Figure x = h;
              if (x.height<0) x.height = maxHeight;
              r+=x;
              }
         z+=[r];
         if (maxHeight<0) nUndefinedRows+=1;
          }
     num computedHeight = -1;
     if (nUndefinedRows>0) computedHeight = (height-definedHeight-size(figArray)*(vgap+2*lw)-vgap-sumLw)/nUndefinedRows;
     return <computedHeight, z>;  
     }
     
 tuple[num, list[list[Figure]]] getWidthMissingCells(int width, int lw, int hgap, list[list[Figure]] figArray ) {
     if (width<0) return <-1, []>;
     figArray = transpose(figArray);
     int nUndefinedCols = 0;
     int definedWidth = 0;
     list[list[Figure]] z =[];
     int sumLw = 0;
     for (list[Figure] g<- figArray) {
         list[Figure] r =[];
         int maxWidth = -1; int maxLw = -1;
         for (Figure h<-g) {
              maxWidth= max(h.width, maxWidth);
              maxLw = max(h.lineWidth, maxLw);
         }
         if (maxWidth>=0) definedWidth= definedWidth+maxWidth;
         if (maxLw>=0) sumLw+=maxLw;
         for (Figure h<-g) {
              Figure x = h;
              if (x.width<0) x.width = maxWidth;
              r+=x;
              }
         z+=[r];
         if (maxWidth<0) nUndefinedCols+=1;    
         }
     num computedWidth = -1;
     if (nUndefinedCols>0) computedWidth = (width-definedWidth-size(figArray)*(hgap+2*lw)-hgap-2*sumLw)/nUndefinedCols;
     return <computedWidth, transpose(z)>;  
     }
     
 Figure pushDim(atXY(num x, num y, Figure g)) {
      g.at = <x, y>;
      return pushDim(g);
      }
     
 Figure pushDim(Figure f:overlay()) {
    if (isEmpty(f.figs)) return f;
    list[Figure] z =[];
    if (f.width>=0)
    for (Figure h<-f.figs) {
       if (f.width>=0 && h.width<0) h.width = f.width;
       if (f.height>=0 && h.height<0) h.height = f.height;
       z+=[h];
       }
    f.figs = [pushDim(h)|h<-z];
    return f;
    }
    
 Figure pushDim(Figure f:salix::lib::Figure::graph()) {
      if (f.size != <0, 0>) {
          if (f.width<0) f.width = f.size[0];
          if (f.height<0) f.height = f.size[1];
       }
      list[tuple[str, Figure]] r = [];
      for (tuple[str id, Figure fig] d<-f.nodes) {
            r+=[<d.id, pushDim(d.fig)>];
            }
      f.nodes = r;
      return f;
      }
     
 default Figure pushDim(Figure f) {
     if (f.size != <0, 0>) {
       if (f.width<0) f.width = f.size[0];
       if (f.height<0) f.height = f.size[1];
       }
     if (hasFigField(f) && emptyFigure()!:=f.fig) {
           Figure g = f.fig;  
           int lwo = round(f.lineWidth); int lwi = round(g.lineWidth);
           if (lwo<0) lwo = 0; if (lwi<0) lwi = 0;
           if (g.width<0 && f.width>=0) g.width = round(g.shrink*(f.width-lwo)) - lwi -round(g.at[0]);
           if (g.height<0 && f.height>=0) g.height = round(g.shrink*(f.height-lwo)) -lwi - round(g.at[1]);
           f.fig = pushDim(g);
     }
     if (grid():=f || vcat():=f || hcat():=f) {
         int lw = round(f.borderWidth);
         if (lw<0) lw = 0;
         list[list[Figure]] figArray = [];
         if (grid():=f) figArray = f.figArray;
         else if (vcat():=f) figArray= [[h]|h<-f.figs]; 
         else if (hcat():=f) figArray  = [f.figs];
         tuple[num height, list[list[Figure]] figs] cellsH = getHeightMissingCells(f.height, lw, f.vgap, figArray);
         tuple[num width, list[list[Figure]] figs] cellsW = getWidthMissingCells(f.width, lw, f.hgap, cellsH.figs);
          list[list[Figure]] z =[];
          for (list[Figure] g<-cellsW.figs) {
              list[Figure] r = [];
              for (Figure h<-g) {  
                  Figure q = h;
                  if (cellsW.width>=0 && q.width<0) q.width =   round(cellsW.width*q.shrink-q.at[0]-lw); 
                  if (cellsH.height>=0 && q.height<0) q.height =   round(cellsH.height*q.shrink-q.at[1]-lw); 
                  r += pushDim(q);  
                  }
              z+=[r];
              }
          if (grid():=f) f.figArray= z;
          else
          if (vcat():=f) f.figs = [head(h)|list[Figure] h<-z];
          else
          if (hcat():=f) f.figs = head(z);
          }
     return f;
     }
     
 Figure solveStepDim(Figure f) {
     f = pullDim(f);
     return pushDim(f);
     }
     
 Figure solveDim(Figure f) {
     return solve(f) solveStepDim(f);
     }
     
 public void fig(Figure f, num width = -1, num height = -1) {
     Figure root = root(width = round(width), height = round(height));
     if (root.size != <0, 0>) {
       if (root.width<0) f.width = f.size[0];
       if (root.height<0) f.height = f.size[1];
       }
     root.fig = f;
     root = solveDim(root);
     eval(root);
     }
/*    
 str adjustText(str v, bool html) {
    if (isEmpty(v)) return "";
    s = replaceAll(v,"\\", "\\\\");
    s = replaceAll(s,"\n", "\\\n");
    s = "\"<replaceAll(s,"\"", "\\\"")>\""; 
    return s;
    }
*/

void translate(tuple[num , num] at, void () g) {
    salix::SVG::svg(salix::SVG::x("<at[0]>"), salix::SVG::y("<at[1]>"), g);
    }
     
void eval(emptyFigure()) {;}

void eval(Figure f:root()) {svg(svgSize(f)+[() {eval(f.fig);}]);}

void eval(Figure f:overlay()) {svg(svgSize(f)+[(){for (g<-f.figs) {svg(svgSize(g)+[() {eval(g);}]);}}]);}

void eval(Figure f:box()) {translate(f.at, (){\rect(fromFigureAttributesToSalix(f));if (emptyFigure()!:=f.fig) innerFig(f, f.fig)();});}

void eval(Figure f:salix::lib::Figure::circle()) {salix::SVG::circle(fromFigureAttributesToSalix(f));if (emptyFigure()!:=f.fig) innerFig(f, f.fig)();}

void eval(Figure f:salix::lib::Figure::ellipse()) {salix::SVG::ellipse(fromFigureAttributesToSalix(f));if (emptyFigure()!:=f.fig) innerFig(f, f.fig)();}

void eval(Figure f:htmlText(value v)) {
     int lw = round(f.lineWidth); 
     if (lw<0) lw = 0;
     int width = f.width; int height = f.height; 
     list[value] foreignObjectArgs = [style(<"line-height", "1.5">)];
     if (width>=0) foreignObjectArgs+= salix::SVG::width("<width-lw>");
     if (height>=0) foreignObjectArgs+= salix::SVG::height("<height-lw>");
     foreignObjectArgs+= salix::SVG::x("<lw>"); foreignObjectArgs+= salix::SVG::y("<lw>");
     list[tuple[str, str]] styles = [<"padding", 
                                      "<round(f.padding[1])> <round(f.padding[2])> <round(f.padding[3])> <round(f.padding[0])>">];
     if (f.borderWidth>=0) styles += <"border-width", "<f.borderWidth>">;
     if (!isEmpty(f.borderColor)) styles+= <"border-color", "<f.borderColor>">;
     if (!isEmpty(f.borderStyle)) styles+= <"border-style", "<f.borderStyle>">;
     if (htmlText(_):=f) {
          if(f.width>=0)  styles+= <"max-width", "<f.width>">;
          if(f.height>=0)  styles+= <"max-height", "<f.height>">;
          if(f.width>=0)  styles+= <"min-width", "<f.width>">;
          if(f.height>=0)  styles+= <"min-height", "<f.height>">;
          }
     list[value] tdArgs =[salix::HTML::style(styles)];
     tdArgs += hAlign(f.align);
     tdArgs += vAlign(f.align); 
     tdArgs+=[salix::HTML::style(styles)];
     list[value] tableArgs = foreignObjectArgs+fromTextPropertiesToSalix(f, false); 
     if(str s:=v) foreignObject(foreignObjectArgs+[(){table(tableArgs+[(){tr((){td(tdArgs+[s]);});}]);}]);
    }
    
 void eval(Figure f:svgText(value v)) {
     if(str s:=v) text_(fromTextPropertiesToSalix(f, true)+[s]);
    }
    
void eval(Figure f:vcat()) {
                   list[value] foreignObjectArgs = [style(<"line-height", "0">)];
                   if (f.width>=0) foreignObjectArgs+= salix::SVG::width("<f.width>");
                   if (f.height>=0) foreignObjectArgs+= salix::SVG::height("<f.height>");
                   foreignObject(foreignObjectArgs+[(){salix::HTML::table(fromTableModelToProperties(f)+[tableRows(f)]);}]);
                   }
                   
void eval(Figure f:hcat()) {
                   list[value] foreignObjectArgs = [style(<"line-height", "0">)];
                   if (f.width>=0) foreignObjectArgs+= salix::SVG::width("<f.width>");
                   if (f.height>=0) foreignObjectArgs+= salix::SVG::height("<f.height>");
                   foreignObject(foreignObjectArgs+[(){salix::HTML::table(fromTableModelToProperties(f)+[tableRows(f)]);}]);
                   }
 

void eval(Figure f:grid()) {
                   list[value] foreignObjectArgs = [style(<"line-height", "0">)];
                   if (f.width>=0) foreignObjectArgs+= salix::SVG::width("<f.width>");
                   if (f.height>=0) foreignObjectArgs+= salix::SVG::height("<f.height>");
                   foreignObject(foreignObjectArgs+[(){salix::HTML::table(fromTableModelToProperties(f)+[tableRows(f)]);}]);
                   }
                   
void eval(Figure f:path(list[str] _)) {
                   list[tuple[Figure fig, str lab]] r =[];
                   int startCode =  getFingerprintNode(f.startMarker);
                   int midCode =  getFingerprintNode(f.midMarker);
                   int endCode =  getFingerprintNode(f.endMarker);
                   if (emptyFigure()!:=f.startMarker) r += <f.startMarker,startCode>0?"startMarker<startCode>":"startMarkerX<startCode>">;
                   if (emptyFigure()!:=f.midMarker)   r += <f.midMarker, midCode>0?"midMarker<midCode>":"midMarkerX<midCode>">;
                   if (emptyFigure()!:=f.endMarker)   r += <f.endMarker, endCode>0?"endMarker<endCode>":"endMarkerX<endCode>">;
                   // println("fingerPrint: <getFingerprintNode(f.midMarker)>");
                   if (!isEmpty(r))
                            salix::SVG::defs(() {
                            for (tuple[Figure fig, str lab] d<-r)
                            salix::SVG::marker(salix::SVG::id(d.lab), markerWidth("<d[0].width/abs(f.scaleX)>"), markerHeight("<d[0].height/abs(f.scaleY)>"),
                              refX("<d[0].width/abs(2.0*f.scaleX)>"), refY("<d[0].height/abs(f.scaleY*2.0)>"), orient("auto"),
                              () {
                                 salix::SVG::g(salix::SVG::transform("scale(<1/f.scaleX>,<1/abs(f.scaleY)>) "),
                                 (){                                               
                                             eval(d.fig);
                                   });
                            });                    
                         });   
                   salix::SVG::g(salix::SVG::transform("translate(<f.at[0]>, <f.at[1]>) scale(<f.scaleX>,<f.scaleY>) "+f.transform),
                          (){                        
                             salix::SVG::path(fromFigureAttributesToSalix(f, r));
                            });
                   }
                   
 void eval (Figure f:ngon()) {
                   num shift = 1.0;
                   num lw = f.lineWidth/cos(PI()/f.n); 
                   if (lw<0) lw = 0;
                   if (f.r<0) f.r = f.width/2;
                   salix::SVG::g(salix::SVG::transform(t_.t(lw/2,lw/2)+"scale(<f.r>,<f.r>) "+t_.t(shift, shift)+t_.r(f.angle, 0, 0)),
                          (){                        
                            list[str] pth = [p_.M(-1, 0)];
                            pth += [p_.L(-cos(phi), sin(phi))|num phi<-[2*PI()/f.n, 4*PI()/f.n..2*PI()]];
                            pth += [p_.Z()];                     
                             salix::SVG::path(fromFigureAttributesToSalix(f, pth));
                            }); 
                   if (emptyFigure()!:=f.fig) innerFig(f, f.fig)();    
                   }
                   
 str shapeName(Figure f) {
      switch(f) {
         case circle():  return "circle";
         case ngon():  return "diamond";
         case ellipse(): return "ellipse";
         default: return "rect";
         }
      return "rect";
      }
                   
 void eval(Figure f:salix::lib::Figure::graph()) {
                  dagre("myGraph", width("<f.width>"), height("<f.height>"), (N n, E e) {
                       for (tuple[str id, Figure fig] d<-f.nodes) {
                           int lw = d.fig.lineWidth>=0?round(d.fig.lineWidth):0;
                           n(d.id,salix::lib::Dagre::shape("<shapeName(d.fig)>"), width("<d.fig.width+lw>"), height("<d.fig.height+lw>"),
                              class("svg"),
                              ngon():=d.fig?nCorner(d.fig.n):0,
                               (){svg(svgSize(d.fig)+[() {eval(d.fig);}]);});
                           }
                       for (Edge edg <- f.edges)
                           if (edge(str from, str to):=edg) {
                               list[value] r =[lineInterpolate(edg.lineInterpolate)];
                               list [tuple[str, str]] styl = [<"fill","none">];  
                               if (!isEmpty(edg.label)) r += edgeLabel(edg.label); 
                               if (!isEmpty(edg.labelStyle)) r += labelStyle(edg.labelStyle); 
                               if (!isEmpty(edg.arrowheadStyle)) r += arrowhead(edg.arrowheadStyle);
                               if (!isEmpty(edg.lineColor)) styl += <"stroke", edg.lineColor>;
                               if (edg.lineWidth>=0) styl += <"stroke-width", "<edg.lineWidth>">;
                               if (!isEmpty(styl)) r+=style(styl);
                               if (edg.labelOffset>=0) r += labelOffset(edg.labelOffset);
                               if (!isEmpty(edg.labelPos)) r += labelPos(edg.labelPos);
                               e(from, to, r);
                           }
                        });
                  }

void eval(Figure f:atXY(num x, num y, Figure g)) {
                   g.at = <x, y>;
                   eval(g);
                   }
     