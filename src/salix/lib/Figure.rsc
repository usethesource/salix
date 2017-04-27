@license{
  Copyright (c) 2009-2015 CWI
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
@contributor{Bert Lisser - Bert.Lisser@cwi.nl (CWI)}
@contributor{Paul Klint - Paul.Klint@cwi.nl - CWI}
module salix::lib::Figure

import util::Math;
import util::Maybe;

/* Properties */

// Position for absolute placement of figure in parent

alias Position = tuple[num x, num y];

alias Rotate = tuple[num angle, num x, num y];

alias Rescale = tuple[tuple[num, num], tuple[num, num]];


// Alignment for relative placement of figure in parent

public alias Alignment = tuple[num hpos, num vpos];

public Alignment topLeft      	= <0.0, 0.0>;
public Alignment topMid          	= <0.5, 0.0>;
public Alignment topRight     	= <1.0, 0.0>;

public Alignment centerLeft   		= <0.0, 0.5>;
public Alignment centerMid     = <0.5, 0.5>;
public Alignment centerRight 	 	= <1.0, 0.5>;

public Alignment bottomLeft   	= <0.0, 1.0>;
public Alignment bottomMid 		= <0.5, 1.0>;
public Alignment bottomRight	= <1.0, 1.0>;


data Orientation =
		leftRight()
	|	rightLeft()
	| 	topDown()
	|	downTop();


// Vertices for defining shapes.

data Vertex
	= line(num x, num y)
	| lineBy(num x, num y)
	| move(num x, num y)
	| moveBy(num x, num y)
	| arc(num rx, num ry, num rotation, bool largeArc, bool sweep, num x, num y)
	;
	
alias Vertices = list[Vertex];

alias Points = lrel[num x, num y];

alias Constraint = tuple[bool(value v) cond, str emsg];

alias FormEntry = tuple[str id, value startValue, str fieldName, list[Constraint] constraints];

public alias Figures = list[Figure];

public data Attr (
    int width = -1,
    int height =  -1,
    int r = -1,
    num bigger = 1.0,
    str d = "",
    bool disabled = false, 
    bool shapeCurved = false 
    ) = attr();
    
public data Property (
     value \value = ""
    ) = property();
    
public data Timer (
     int delay = -1,
     str command = ""
     // ,str mark = ""
    ) = timer();
    
    
public data Style (	
    bool svg = false,
    str visibility = "", 
    int width = -1,
    int height = -1,	
    int lineWidth = -1,			
    str lineColor = "Black", 
    str fillColor= "", 
    num fillOpacity = -1.0, 
    num lineOpacity= -1.0   
    ) = style();
    
    
public data Text (		
    str plain = "",
    str html = ""  
    ) = text();
    
    
public alias Prop =
    tuple[Attr attr, Style style,  Property property, Text text, Timer timer];
    

 
public data Figure(
        // Naming
        str id = "",
        str visibility = "",  // hidden | visible
		// Dimensions and Alignmenting
		tuple[int,int] size = <0,0>,
		tuple[int left, int top, int right, int bottom] padding = <0, 0, 0, 0>, // left, top, right, bottom 
		int width = -1,
		int height = -1,
		Position at = <0, 0>,
		Rotate rotate = <0, -1, -1>, 
		Alignment align = <0.5, 0.5>,
		Alignment cellAlign = <-1, -1>, 
		num bigger = 1.0,
		num shrink = 1.0, 
		num hshrink = 1.0, 
		num vshrink = 1.0, 
		num grow = 1.0, 
		num hgrow = 1.0, 
		num vgrow = 1.0, 
		bool resizable = true,
		tuple[int,int] gap = <0,0>,
		int hgap = 0,
		int vgap = 0,
    bool sizeFromParent = false,
    bool print = true, 
  	// Line properties
		int lineWidth = -1,			
		str lineColor = "Black", 		
		list[int] lineDashing = [],	
		num lineOpacity = -1,
	
		// Area properties
		str fillColor    = "none", 			
		num fillOpacity = -1,	
		str fillRule     = "evenodd",
		list[str] clipPath = [],
		
		tuple[int, int] rounded = <0, 0>,

		// Font and text properties
		
		str fontFamily = "",// "Helvetica, Arial, Verdana, sans-serif",
		str fontName = "", // "Helvetica",
		int fontSize = -1, // 12,
		str fontStyle = "",  //  normal|italic|oblique|initial|inherit   
		str fontWeight = "", // normal|bold|bolder|lighter|number|initial|inherit; normal==400, bold==700
		str fontColor = "",  // default "black",
		str textDecoration	= "", // none|underline|overline|line-through|initial|inherit
		num fontLineWidth = -1,
		str fontLineColor = "",
		
		
		// In tables
		int rowspan = -1,
		int colspan = -1,
		str borderStyle="",  // solid|dotted|double|groove|ridge|inset|outset
		int borderWidth=-1, 
		str borderColor = "",
		str borderTopStyle="", 
		int borderTopWidth=-1, 
		str borderTopColor = "",
		str borderBottomStyle="", 
		int borderBottomWidth=-1, 
		str borderBottomColor = "",
		str borderLeftStyle="", 
		int borderLeftWidth=-1, 
		str borderLeftColor = "",
		str borderRightStyle="", 
		int borderRightWidth=-1, 
		str borderRightColor = "",
		// Interaction
		// temporary
		//value event = -1,
		
		// Tooltip
		value tooltip = "",
		
		// Panel
		Figure panel = emptyFigure()
	) =
	
	emptyFigure(int seq = 0)
  

	
   | htmlText(value text, str overflow = "hidden")		    			// text label html
   | svgText(value text, str overflow = "hidden")		    			// text label html
   | text(value text, str overflow = "hidden")		    			// text label svg
// | markdown(value text)					// text with markdown markup (TODO: make flavor of text?)
// | math(value text)						// text with latex markup
   
// Graphical elements

   | box(Figure fig=emptyFigure())      	// rectangular box with inner element
   
   | ellipse(num cx = -1, num cy = -1, num rx=-1, num ry=-1, Figure fig=emptyFigure())
   
   | circle(num cx = -1, num cy = -1, num r=-1, Figure fig=emptyFigure())

// regular polygon   
   | ngon(int n=3, num r=-1, num angle = 0, Figure fig=emptyFigure(),
        Rescale scaleX = <<0,1>, <0, 1>>,
   	    Rescale scaleY = <<0,1>, <0, 1>>
     )	
   
   | polygon(Points points=[], bool fillEvenOdd = true,
            bool yReverse = false,
            Rescale scaleX = <<0,1>, <0, 1>>,
   			Rescale scaleY = <<0,1>, <0, 1>>)
   
   | shape(list[Vertex] vertices, 				// Arbitrary shape
   			bool shapeConnected = true, 	// Connect vertices with line/curve
   			bool shapeClosed = false, 		// Make a closed shape
   			bool shapeCurved = false, 		// Connect vertices with a spline
   			bool fillEvenOdd = true,
   			bool yReverse = true,		
   			Rescale scaleX = <<0,1>, <0, 1>>,
   			Rescale scaleY = <<0,1>, <0, 1>>,
   			Figure startMarker=emptyFigure(),
   			Figure midMarker=emptyFigure(),
   			Figure endMarker=emptyFigure()) 
   	| path(str transform, num scale, num xp, num yp, list[str] dd, 				// Arbitrary shape
    	// Connect vertices with line/curve
   			bool fillEvenOdd = true,		
   			Figure startMarker=emptyFigure(),
   			Figure midMarker=emptyFigure(), 
   			Figure endMarker=emptyFigure())	
    | textPath(str transform, num scale, num xp, num yp, list[str] dd, 	list[str] label		// Arbitrary shape
    	// Connect vertices with line/curve
   			bool fillEvenOdd = true,		
   			bool display = false
   			)
   | image(str src="")

// Figure composers
// borderStyle =  none|hidden|dotted|dashed|solid|double|groove|ridge|inset|outset|initial|inherit;              
   | hcat(Figures figs=[], bool form= false) 					// horizontal and vertical concatenation
   | vcat(Figures figs=[], bool form= false) 					// horizontal and vertical concatenation 
   | overlay(Figures figs=[])				
   | grid(list[Figures] figArray = [], bool form= false) 	// grid of figures

// Figure transformations

   | atXY(int x, int y, Figure fig)	
   | atXY(tuple[int x, int y] xy, Figure fig)			// Move to Alignment relative to origin of enclosing Figure
   | atX(int x, Figure fig)				// TODO: how to handle negative values?
   | atY(int y, Figure fig)
   
   | rotateDeg(num angle, int x, int y, Figure fig)
   | rotateDeg(num angle, Figure fig)
   
// Input elements
   | buttonInput(str txt, bool disabled=false,  value \value = "")
   | checkboxInput(list[str] choices = ["0"], value \value = (), value labels=())
   | choiceInput(list[str] choices = ["0"], value \value = "")
   // | colorInput()
   // date
   // datetime
   // email
   // month
   // time
   // tel
   // week
   // url
   
  //  | numInput()
   | rangeInput(num low=0, num high=100, num step=1, value \value = 50.0)
   | strInput(int nchars=20, value \value="", bool keydown= true) 
   | choice(int selection = 0, Figures figs = [])
   ;
   

public Figure idEllipse(num rx, num ry) = ellipse(rx=rx, ry = ry, lineWidth = 0, fillColor = "none");

public Figure idCircle(num r) = circle(r= r, lineWidth = 0, fillColor = "none");

public Figure idNgon(int n, num r) = ngon(n=  n, r= r, lineWidth = 0, fillColor = "none");

public Figure idRect(int width, int height) = box(width = width, height = height, lineWidth = 0, fillColor = "none");

      
public Figure plot(Points xy, Rescale x, Rescale y, bool shapeCurved = true
      ,str lineColor = "", int lineWidth = -1, str fillColor = ""
      , int width = -1, int height = -1
      , bool fillEvenOdd = true
      ) {
      Vertices v = [move(head(xy)[0], head(xy)[1])]
                  +[line(d[0], d[1])|d<-tail(xy)];
      return shape(v, scaleX = x, scaleY = y, shapeCurved = shapeCurved,
      lineColor = lineColor, lineWidth = lineWidth, fillColor = fillColor,
      width = width, height = height, fillEvenOdd = fillEvenOdd);
      }

public Figure frame(Figure f, num shrink=1.0, num grow=1.0, str id = "", str visibility="visible", int borderWidth = -1, 
      str borderStyle = "") {
      return box(lineWidth=0, fillColor="none", fig = f, shrink= shrink, grow = grow, id = false?"<newId()>_frame":id
      , visibility = visibility, borderWidth=borderWidth, borderStyle= borderStyle);
      }
      
public Figure circleSegment(num cx = 100, num cy =100, num r =50, num startAngle = 0, num endAngle =60,
      str fillColor = "", str lineColor = "", int lineWidth = -1, bool fill = true,tuple[int,int] size = <0,0>
      ) {
      num x1 = cx+ r*cos(startAngle/180*PI());
      num y1 = cy+ r*sin(startAngle/180*PI());
      num x2 = cx +r*cos(endAngle/180*PI());
      num y2 = cy +r*sin(endAngle/180*PI());
      Vertices v = [move(x1, y1), arc(r, r, 0, false, true, x2, y2)];
      if (fill) v+= [line(cx, cy)];
      return shape(v, fillColor = fillColor, lineColor = lineColor, lineWidth = lineWidth, shapeClosed=fill, size = size);
      }
      
int currentColor = 7;

public void resetColor() {currentColor = 7;} 

public str pickColor() {int r = currentColor;currentColor = (currentColor+3)%size(colors); return colors[r][0];}

public str figToString(Figure f) {
     str r = "<f>";
     r = replaceAll(r, "\<0.0,0.0\>", "topLeft");
     r = replaceAll(r, "\<0.5,0.0\>", "topMid");
     r = replaceAll(r, "\<1.0,0.0\>", "topRight");
     r = replaceAll(r, "\<0.0,0.5\>", "centerLeft");
     r = replaceAll(r, "\<0.5,0.5\>", "centerMid");
     r = replaceAll(r, "\<1.0,0.5\>", "centerRight");
     r = replaceAll(r, "\<0.0,1.0\>", "bottomLeft");
     r = replaceAll(r, "\<0.5,1.0\>", "bottomMid");
     r = replaceAll(r, "\<1.0,1.0\>", "bottomRight");
     return r;
     }
     
str getColorCode(str color) {
     int idx =    indexOf(domain(colors), color);
     if (idx>=0) {
          return colors[idx][1];
          }
     return "";
     }
     
 
lrel[str, str] colors = 
[
  <"aliceblue","#f0f8ff">,
  <"antiquewhite","#faebd7">,
  <"aqua","#00ffff">,
  <"aquamarine","#7fffd4">,
  <"azure","#f0ffff">,
  <"beige","#f5f5dc">,
  <"bisque","#ffe4c4">,
  <"black","#000000">,
  <"blanchedalmond","#ffebcd">,
  <"blue","#0000ff">,
  <"blueviolet","#8a2be2">,
  <"brown","#a52a2a">,
  <"burlywood","#deb887">,
  <"cadetblue","#5f9ea0">,
  <"chartreuse","#7fff00">,
  <"chocolate","#d2691e">,
  <"coral","#ff7f50">,
  <"cornflowerblue","#6495ed">,
  <"cornsilk","#fff8dc">,
  <"crimson","#dc143c">,
  <"cyan","#00ffff">,
  <"darkblue","#00008b">,
  <"darkcyan","#008b8b">,
  <"darkgoldenrod","#b8860b">,
  <"darkgray","#a9a9a9">,
  <"darkgreen","#006400">,
  <"darkgrey","#a9a9a9">,
  <"darkkhaki","#bdb76b">,
  <"darkmagenta","#8b008b">,
  <"darkolivegreen","#556b2f">,
  <"darkorange","#ff8c00">,
  <"darkorchid","#9932cc">,
  <"darkred","#8b0000">,
  <"darksalmon","#e9967a">,
  <"darkseagreen","#8fbc8f">,
  <"darkslateblue","#483d8b">,
  <"darkslategray","#2f4f4f">,
  <"darkslategrey","#2f4f4f">,
  <"darkturquoise","#00ced1">,
  <"darkviolet","#9400d3">,
  <"deeppink","#ff1493">,
  <"deepskyblue","#00bfff">,
  <"dimgray","#696969">,
  <"dimgrey","#696969">,
  <"dodgerblue","#1e90ff">,
  <"firebrick","#b22222">,
  <"floralwhite","#fffaf0">,
  <"forestgreen","#228b22">,
  <"fuchsia","#ff00ff">,
  <"gainsboro","#dcdcdc">,
  <"ghostwhite","#f8f8ff">,
  <"gold","#ffd700">,
  <"goldenrod","#daa520">,
  <"gray","#808080">,
  <"green","#008000">,
  <"greenyellow","#adff2f">,
  <"grey","#808080">,
  <"honeydew","#f0fff0">,
  <"hotpink","#ff69b4">,
  <"indianred","#cd5c5c">,
  <"indigo","#4b0082">,
  <"ivory","#fffff0">,
  <"khaki","#f0e68c">,
  <"lavender","#e6e6fa">,
  <"lavenderblush","#fff0f5">,
  <"lawngreen","#7cfc00">,
  <"lemonchiffon","#fffacd">,
  <"lightblue","#add8e6">,
  <"lightcoral","#f08080">,
  <"lightcyan","#e0ffff">,
  <"lightgoldenrodyellow","#fafad2">,
  <"lightgray","#d3d3d3">,
  <"lightgreen","#90ee90">,
  <"lightgrey","#d3d3d3">,
  <"lightpink","#ffb6c1">,
  <"lightsalmon","#ffa07a">,
  <"lightseagreen","#20b2aa">,
  <"lightskyblue","#87cefa">,
  <"lightslategray","#778899">,
  <"lightslategrey","#778899">,
  <"lightsteelblue","#b0c4de">,
  <"lightyellow","#ffffe0">,
  <"lime","#00ff00">,
  <"limegreen","#32cd32">,
  <"linen","#faf0e6">,
  <"magenta","#ff00ff">,
  <"maroon","#800000">,
  <"mediumaquamarine","#66cdaa">,
  <"mediumblue","#0000cd">,
  <"mediumorchid","#ba55d3">,
  <"mediumpurple","#9370db">,
  <"mediumseagreen","#3cb371">,
  <"mediumslateblue","#7b68ee">,
  <"mediumspringgreen","#00fa9a">,
  <"mediumturquoise","#48d1cc">,
  <"mediumvioletred","#c71585">,
  <"midnightblue","#191970">,
  <"mintcream","#f5fffa">,
  <"mistyrose","#ffe4e1">,
  <"moccasin","#ffe4b5">,
  <"navajowhite","#ffdead">,
  <"navy","#000080">,
  <"oldlace","#fdf5e6">,
  <"olive","#808000">,
  <"olivedrab","#6b8e23">,
  <"orange","#ffa500">,
  <"orangered","#ff4500">,
  <"orchid","#da70d6">,
  <"palegoldenrod","#eee8aa">,
  <"palegreen","#98fb98">,
  <"paleturquoise","#afeeee">,
  <"palevioletred","#db7093">,
  <"papayawhip","#ffefd5">,
  <"peachpuff","#ffdab9">,
  <"peru","#cd853f">,
  <"pink","#ffc0cb">,
  <"plum","#dda0dd">,
  <"powderblue","#b0e0e6">,
  <"purple","#800080">,
  <"rebeccapurple","#663399">,
  <"red","#ff0000">,
  <"rosybrown","#bc8f8f">,
  <"royalblue","#4169e1">,
  <"saddlebrown","#8b4513">,
  <"salmon","#fa8072">,
  <"sandybrown","#f4a460">,
  <"seagreen","#2e8b57">,
  <"seashell","#fff5ee">,
  <"sienna","#a0522d">,
  <"silver","#c0c0c0">,
  <"skyblue","#87ceeb">,
  <"slateblue","#6a5acd">,
  <"slategray","#708090">,
  <"slategrey","#708090">,
  <"snow","#fffafa">,
  <"springgreen","#00ff7f">,
  <"steelblue","#4682b4">,
  <"tan","#d2b48c">,
  <"teal","#008080">,
  <"thistle","#d8bfd8">,
  <"tomato","#ff6347">,
  <"turquoise","#40e0d0">,
  <"violet","#ee82ee">,
  <"wheat","#f5deb3">,
  <"white","#ffffff">,
  <"whitesmoke","#f5f5f5">,
  <"yellow","#ffff00">,
  <"yellowgreen","#9acd32">
];

public str randomColor() =  colors[arbInt(size(colors))][0];
 
 
 Figure(Figure , str ) self(Figure g) {return 
              Figure(Figure f, value c) {g.fig = f; return g;}
              ;}
              
public str newName() {
  occur+=1;
  return "myName<occur>";
  }
  
public str newId() {
  occur+=1;
  return "myName<occur>";
  }
  
str fileName(loc l) {
     str p = l.path;
     int n = findLast(p, "/");
     return substring(p, n+1, size(p));
     }
     
map[str, list[list[str]]] _compact(list[list[str]] xs) { 
    if (isEmpty(xs)) return ();  
    map[str,  list[list[str]]] r = ();
    for (list[str] x<-xs) {
         list[list[str]] q = ((r[head(x)]?)? r[head(x)]+[tail(x)]:[tail(x)]);
         r[head(x)] = q;
         }
    return r;
    }
  
//list[DDD] compact(list[list[str]] xs, map[loc, int] m, loc path) {
//    map[str, list[list[str]]] q = _compact(xs);
//    list[DDD] r = [];
//    for (str x<-q) {
//         if (isEmpty(head(q[x]))) r = r + ddd(name=substring(x, 0, findLast(x, ".")), size=m[path+x]); 
//         else r = r + ddd(name=x, children=compact(q[x], m, path +x));
//         }
//    return r;
//    }
//  
//public DDD fileMap(loc source, str suffix) {
//    list[loc] todo = [source];
//    list[loc] done = [];
//    while (!isEmpty(todo)) {
//        <elem,todo> = takeOneFrom(todo);
//        for (e <- listEntries(elem)) {
//           loc f = elem +e;
//		   if (isDirectory(f)) {
//		   	todo += f;
//		   }
//		   else {
//		        if (endsWith(f.path, suffix))
//		        done += f;
//		   }
//	      }
//	    }
//        map[loc, int] m = (d:size(readFileLines(d))|d<-done);
//        list[list[str]] r = [];
//        for (d<-done) {
//            str p = d.path; 
//            r=r+[split("/", p)];
//            }
//        list[DDD] p = compact(r, m, source.parent);
//        return head(p);
//    }
 
 public tuple[int, int](num, num) lattice(int width, int height, int nx, int ny) {
     return tuple[int, int](num x, num y){return <toInt((x*width)/nx), toInt((y*height)/ny)>;};
     }
     
 public int (num) latticeX(int width, int nx) {
     return int(num x){return toInt((x*width)/nx);};
     }
     
 public int(num) latticeY(int height, int ny) {
     return int(num y){return toInt((y*height)/ny);};
     }
	
public Figures intercalate(Figure sep, Figures l) =
     (isEmpty(l)) ? [] : ( [head(l)] | it + [sep, x] | Figure x <-tail(l) );

     
   
alias Clip = tuple[str(int x, int y, int w, int h) rect, str(int cx, int cy, int r) circle, str(list[str]) path] ;

alias Path = tuple[
             str(num x, num y) M, str(num x, num y) m, str(num x, num y) L, str(num x, num y) l,
             str(num cx1, num cy1, num cx2, num cy2, num x, num y) C, str(num cx1, num cy1, num cx2, num cy2, num x, num y) c,
             str(num cx, num cy, num x, num y) S, str(num cx, num cy, num x, num y) s, str() Z,
             str(num r) dot,
             str(num r1, num r2, num phi) segment
             ]
             ;
             
alias Transform = tuple[str(num x, num y) t // translate
                       ,str(num s) s//scale
                       ,str(num phi, num x, num y) r//rotate in radians
                       ]; 

public Clip clip= <
           str(num x, num y, num w, num h) {
              return "\<rect x=\"<x>\" y=\"<y>\"  width=\"<w>\" height=\"<h>\" /\>";
           }
           ,
           str(num r, num cx, num cy) {
              return "\<circle r=\"<r>\" cx=\"<cx>\" cy=\"<cy>\" /\>";
           }
           ,
           str(list[str] p) {
                return "\<path d=\"<intercalate(",", p) >\" /\>";
               }
           >;
           
    
           
 str toP(num d) {
        num v = abs(d);
        return "<d<0?"-":""><toInt(v)>.<toInt(v*10)%10><toInt(v*100)%10><toInt(v*1000)%10>";
        }
        
 str segment(num r1, num r2, num phi) {
        return "m <toP(-r1)> 0 " 
              +"a <toP(r1)> <toP(r1)> 0 0 1 <toP(r1-r1*cos(phi))> <toP(-r1*sin(phi))> "
              +"l <toP((r1-r2)*cos(phi))> <toP((r1-r2)*sin(phi))> "
              +"a <toP(r2)> <toP(r2)> 0 0 0<toP(-r2+r2*cos(phi))>  <toP(r2*sin(phi))>"             
              +"l <toP(r2-r1)> 0"
             ;
        }
  
 public Path p_ = <
                      str(num x, num y) {return "M <toP(x)> <toP(y)>";}
                      ,
                      str(num x, num y) {return "m <toP(x)> <toP(y)>";}
                      ,
                      str(num x, num y) {return "L <toP(x)> <toP(y)>";}
                      ,
                      str(num x, num y) {return "l <toP(x)> <toP(y)>";}
                      ,
                      str(num cx1, num cy1, num cx2, num cy2, num x, num y) {
                           return "C <toP(cx1)> <toP(cy1)> <toP(cx2)> <toP(cy2)> <toP(x)> <toP(y)>";
                           }
                      ,
                      str(num cx1, num cy1, num cx2, num cy2, num x, num y) {
                           return "c <toP(cx1)> <toP(cy1)> <toP(cx2)> <toP(cy2)> <toP(x)> <toP(y)>";
                           }
                      ,
                      str(num cx, num cy, num x, num y) {return "S <toP(cx)> <toP(cy)> <toP(x)> <toP(y)>";}
                      ,
                      str(num cx, num cy,  num x, num y) {return "s <toP(cx)> <toP(cy)> <toP(x)> <toP(y)>";}
                      ,
                      str() {return " Z";}
                      ,
                      str(num r) { return "m <toP(  -r)> 0 a <toP(r)> <toP(r)> 0 1 0 <toP( 2*r)>  0"
                                                         +"a <toP(r)> <toP(r)> 0 1 0 <toP(-2*r)>  0"              
                                                        ;}
                      ,
                      str(num r1, num r2, num phi) {return segment(r1, r2, phi);}                               
                     >;    
                     
 public Transform t_ = <
                         str(num x, num y) {return "translate(<toP(x)>, <toP(y)>)";}
                         ,
                         str(num s) {return "scale(<toP(s)>)";}
                         ,
                         str(num phi, num x, num y) {return "rotate(<toP(phi*180/PI())>,<toP(x)>, <toP(y)>)";}                 
                       >;
                          
     