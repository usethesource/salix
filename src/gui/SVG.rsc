module gui::SVG

Html svgElement(str name, list[Html] kids, map[str,str] attrs, map[str, str] props, map[str, Decoder] events)
  = element(name, kids, attrs, props + ("namespace": "http://www.w3.org/2000/svg"), events);
  
// User functions

void svg(value vals...) = build(vals, _svg);
void animate(value vals...) = build(vals, _animate);
void animateColor(value vals...) = build(vals, _animateColor);
void animateMotion(value vals...) = build(vals, _animateMotion);
void animateTransform(value vals...) = build(vals, _animateTransform);
void mpath(value vals...) = build(vals, _mpath);
void \set(value vals...) = build(vals, _set);

// Container elements

void a(value vals...) = build(vals, _a);
void defs(value vals...) = build(vals, _defs);
void g(value vals...) = build(vals, _g);
void marker(value vals...) = build(vals, _marker);
void mask(value vals...) = build(vals, _mask);
void pattern(value vals...) = build(vals, _pattern);
void \switch(value vals...) = build(vals, _switch);
void symbol(value vals...) = build(vals, _symbol);

// Descriptive elements

void desc(value vals...) = build(vals, _desc);
void metadata(value vals...) = build(vals, _metadata);
void title(value vals...) = build(vals, _title);

// Filter primitive elements

void feBlend(value vals...) = build(vals, _feBlend);
void feColorMatrix(value vals...) = build(vals, _feColorMatrix);
void feComponentTransfer(value vals...) = build(vals, _feComponentTransfer);
void feComposite(value vals...) = build(vals, _feComposite);
void feConvolveMatrix(value vals...) = build(vals, _feConvolveMatrix);
void feDiffuseLighting(value vals...) = build(vals, _feDiffuseLighting);
void feDisplacementMap(value vals...) = build(vals, _feDisplacementMap);
void feFlood(value vals...) = build(vals, _feFlood);
void feFuncA(value vals...) = build(vals, _feFuncA);
void feFuncB(value vals...) = build(vals, _feFuncB);
void feFuncG(value vals...) = build(vals, _feFuncG);
void feFuncR(value vals...) = build(vals, _feFuncR);
void feGaussianBlur(value vals...) = build(vals, _feGaussianBlur);
void feImage(value vals...) = build(vals, _feImage);
void feMerge(value vals...) = build(vals, _feMerge);
void feMergeNode(value vals...) = build(vals, _feMergeNode);
void feMorphology(value vals...) = build(vals, _feMorphology);
void feOffset(value vals...) = build(vals, _feOffset);
void feSpecularLighting(value vals...) = build(vals, _feSpecularLighting);
void feTile(value vals...) = build(vals, _feTile);
void feTurbulence(value vals...) = build(vals, _feTurbulence);


// Font elements

void font(value vals...) = build(vals, _font);


// Gradient elements

void linearGradient(value vals...) = build(vals, _linearGradient);
void radialGradient(value vals...) = build(vals, _radialGradient);
void stop(value vals...) = build(vals, _stop);


// Graphics elements

/* The circle element is an SVG basic shape, used to create circles based on
a center point and a radius.
    circle [ cx "60", cy "60", r "50" ] []
*/
void circle(value vals...) = build(vals, _circle);
void ellipse(value vals...) = build(vals, _ellipse);
void image(value vals...) = build(vals, _image);
void line(value vals...) = build(vals, _line);
void path(value vals...) = build(vals, _path);
void polygon(value vals...) = build(vals, _polygon);

/*| The polyline element is an SVG basic shape, used to create a series of
straight lines connecting several points. Typically a polyline is used to
create open shapes.
    polyline [ fill "none", stroke "black", points "20,100 40,60 70,80 100,20" ] []
*/
void polyline(value vals...) = build(vals, _polyline);
void rect(value vals...) = build(vals, _rect);
void use(value vals...) = build(vals, _use);


// Light source elements

void feDistantLight(value vals...) = build(vals, _feDistantLight);
void fePointLight(value vals...) = build(vals, _fePointLight);
void feSpotLight(value vals...) = build(vals, _feSpotLight);

// Text content elements

void altGlyph(value vals...) = build(vals, _altGlyph);
void altGlyphDef(value vals...) = build(vals, _altGlyphDef);
void altGlyphItem(value vals...) = build(vals, _altGlyphItem);
void glyph(value vals...) = build(vals, _glyph);
void glyphRef(value vals...) = build(vals, _glyphRef);
void textPath(value vals...) = build(vals, _textPath);
void text_(value vals...) = build(vals, _text_);
void tref(value vals...) = build(vals, _tref);
void tspan(value vals...) = build(vals, _tspan);

// Uncategorized elements

void clipPath(value vals...) = build(vals, _clipPath);
void colorProfile(value vals...) = build(vals, _colorProfile);
void cursor(value vals...) = build(vals, _cursor);
void \filter(value vals...) = build(vals, _filter);
void script(value vals...) = build(vals, _script);
void style(value vals...) = build(vals, _style);
void view(value vals...) = build(vals, _view);
  

  
  
  
// basics  
  
Html _svg(list[Html] kids, list[Attrs] attrs)
  = svgElement("svg", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _animate(list[Html] kids, list[Attrs] attrs)
  = svgElement("animate", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _animateColor(list[Html] kids, list[Attrs] attrs)
  = svgElement("animateColor", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _animateMotion(list[Html] kids, list[Attrs] attrs)
  = svgElement("animateMotion", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _animateTransform(list[Html] kids, list[Attrs] attrs)
  = svgElement("animateTransform", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _mpath(list[Html] kids, list[Attrs] attrs)
  = svgElement("mpath", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _set(list[Html] kids, list[Attrs] attrs)
  = svgElement("set", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

// Container elements

Html _a(list[Html] kids, list[Attrs] attrs)
  = svgElement("a", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _defs(list[Html] kids, list[Attrs] attrs)
  = svgElement("defs", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _g(list[Html] kids, list[Attrs] attrs)
  = svgElement("g", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _marker(list[Html] kids, list[Attrs] attrs)
  = svgElement("marker", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _mask(list[Html] kids, list[Attrs] attrs)
  = svgElement("mask", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _pattern(list[Html] kids, list[Attrs] attrs)
  = svgElement("pattern", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _switch(list[Html] kids, list[Attrs] attrs)
  = svgElement("switch", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _symbol(list[Html] kids, list[Attrs] attrs)
  = svgElement("symbol", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

// Descriptive elements

Html _desc(list[Html] kids, list[Attrs] attrs)
  = svgElement("desc", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _metadata(list[Html] kids, list[Attrs] attrs)
  = svgElement("metadata", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _title(list[Html] kids, list[Attrs] attrs)
  = svgElement("title", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

// Filter primitive elements

Html _feBlend(list[Html] kids, list[Attrs] attrs)
  = svgElement("feBlend", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _feColorMatrix(list[Html] kids, list[Attrs] attrs)
  = svgElement("feColorMatrix", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _feComponentTransfer(list[Html] kids, list[Attrs] attrs)
  = svgElement("feComponentTransfer", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _feComposite(list[Html] kids, list[Attrs] attrs)
  = svgElement("feComposite", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _feConvolveMatrix(list[Html] kids, list[Attrs] attrs)
  = svgElement("feConvolveMatrix", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));


Html _feDiffuseLighting(list[Html] kids, list[Attrs] attrs)
  = svgElement("feDiffuseLighting", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _feDisplacementMap(list[Html] kids, list[Attrs] attrs)
  = svgElement("feDisplacementMap", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _feFlood(list[Html] kids, list[Attrs] attrs)
  = svgElement("feFlood", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _feFuncA(list[Html] kids, list[Attrs] attrs)
  = svgElement("feFuncA", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _feFuncB(list[Html] kids, list[Attrs] attrs)
  = svgElement("feFuncB", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _feFuncG(list[Html] kids, list[Attrs] attrs)
  = svgElement("feFuncG", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _feFuncR(list[Html] kids, list[Attrs] attrs)
  = svgElement("feFuncR", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _feGaussianBlur(list[Html] kids, list[Attrs] attrs)
  = svgElement("feGaussianBlur", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _feImage(list[Html] kids, list[Attrs] attrs)
  = svgElement("feImage", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _feMerge(list[Html] kids, list[Attrs] attrs)
  = svgElement("feMerge", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _feMergeNode(list[Html] kids, list[Attrs] attrs)
  = svgElement("feMergeNode", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _feMorphology(list[Html] kids, list[Attrs] attrs)
  = svgElement("feMorphology", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _feOffset(list[Html] kids, list[Attrs] attrs)
  = svgElement("feOffset", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _feSpecularLighting(list[Html] kids, list[Attrs] attrs)
  = svgElement("feSpecularLighting", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _feTile(list[Html] kids, list[Attrs] attrs)
  = svgElement("feTile", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _feTurbulence(list[Html] kids, list[Attrs] attrs)
  = svgElement("feTurbulence", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));


// Font elements

Html _font(list[Html] kids, list[Attrs] attrs)
  = svgElement("font", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

// Gradient elements

Html _linearGradient(list[Html] kids, list[Attrs] attrs)
  = svgElement("linearGradient", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _radialGradient(list[Html] kids, list[Attrs] attrs)
  = svgElement("radialGradient", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _stop(list[Html] kids, list[Attrs] attrs)
  = svgElement("stop", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

// Graphics elements

/* The circle element is an SVG basic shape, used to create circles based on
a center point and a radius.
    circle [ cx "60", cy "60", r "50" ] []
*/
Html _circle(list[Html] kids, list[Attrs] attrs)
  = svgElement("circle", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _ellipse(list[Html] kids, list[Attrs] attrs)
  = svgElement("ellipse", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _image(list[Html] kids, list[Attrs] attrs)
  = svgElement("image", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _line(list[Html] kids, list[Attrs] attrs)
  = svgElement("line", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _path(list[Html] kids, list[Attrs] attrs)
  = svgElement("path", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _polygon(list[Html] kids, list[Attrs] attrs)
  = svgElement("polygon", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

/*| The polyline element is an SVG basic shape, used to create a series of
straight lines connecting several points. Typically a polyline is used to
create open shapes.
    polyline [ fill "none", stroke "black", points "20,100 40,60 70,80 100,20" ] []
*/
Html _polyline(list[Html] kids, list[Attrs] attrs)
  = svgElement("polyline", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _rect(list[Html] kids, list[Attrs] attrs)
  = svgElement("rect", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _use(list[Html] kids, list[Attrs] attrs)
  = svgElement("use", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

// Light source elements

Html _feDistantLight(list[Html] kids, list[Attrs] attrs)
  = svgElement("feDistantLight", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _fePointLight(list[Html] kids, list[Attrs] attrs)
  = svgElement("fePointLight", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _feSpotLight(list[Html] kids, list[Attrs] attrs)
  = svgElement("feSpotLight", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

// Text content elements

Html _altGlyph(list[Html] kids, list[Attrs] attrs)
  = svgElement("altGlyph", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _altGlyphDef(list[Html] kids, list[Attrs] attrs)
  = svgElement("altGlyphDef", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _altGlyphItem(list[Html] kids, list[Attrs] attrs)
  = svgElement("altGlyphItem", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _glyph(list[Html] kids, list[Attrs] attrs)
  = svgElement("glyph", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _glyphRef(list[Html] kids, list[Attrs] attrs)
  = svgElement("glyphRef", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _textPath(list[Html] kids, list[Attrs] attrs)
  = svgElement("textPath", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _text_(list[Html] kids, list[Attrs] attrs)
  = svgElement("text", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _tref(list[Html] kids, list[Attrs] attrs)
  = svgElement("tref", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _tspan(list[Html] kids, list[Attrs] attrs)
  = svgElement("tspan", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

// Uncategorized elements

Html _clipPath(list[Html] kids, list[Attrs] attrs)
  = svgElement("clipPath", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _colorProfile(list[Html] kids, list[Attrs] attrs)
  = svgElement("colorProfile", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _cursor(list[Html] kids, list[Attrs] attrs)
  = svgElement("cursor", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _filter(list[Html] kids, list[Attrs] attrs)
  = svgElement("filter", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _script(list[Html] kids, list[Attrs] attrs)
  = svgElement("script", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _style(list[Html] kids, list[Attrs] attrs)
  = svgElement("style", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Html _view(list[Html] kids, list[Attrs] attrs)
  = svgElement("view", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

// Attributes

Attr accentHeight(str val) = attr("accent-height", val);
Attr accelerate(str val) = attr("accelerate", val);
Attr accumulate(str val) = attr("accumulate", val);
Attr additive(str val) = attr("additive", val);
Attr alphabetic(str val) = attr("alphabetic", val);
Attr allowReorder(str val) = attr("allowReorder", val);
Attr amplitude(str val) = attr("amplitude", val);
Attr arabicForm(str val) = attr("arabic-form", val);
Attr ascent(str val) = attr("ascent", val);
Attr attributeName(str val) = attr("attributeName", val);
Attr attributeType(str val) = attr("attributeType", val);
Attr autoReverse(str val) = attr("autoReverse", val);
Attr azimuth(str val) = attr("azimuth", val);
Attr baseFrequency(str val) = attr("baseFrequency", val);
Attr baseProfile(str val) = attr("baseProfile", val);
Attr bbox(str val) = attr("bbox", val);
Attr begin(str val) = attr("begin", val);
Attr bias(str val) = attr("bias", val);
Attr by(str val) = attr("by", val);
Attr calcMode(str val) = attr("calcMode", val);
Attr capHeight(str val) = attr("cap-height", val);
Attr class(str val) = attr("class", val);
Attr clipPathUnits(str val) = attr("clipPathUnits", val);
Attr contentScriptType(str val) = attr("contentScriptType", val);
Attr contentStyleType(str val) = attr("contentStyleType", val);
Attr cx(str val) = attr("cx", val);
Attr cy(str val) = attr("cy", val);
Attr d(str val) = attr("d", val);
Attr decelerate(str val) = attr("decelerate", val);
Attr descent(str val) = attr("descent", val);
Attr diffuseConstant(str val) = attr("diffuseConstant", val);
Attr divisor(str val) = attr("divisor", val);
Attr dur(str val) = attr("dur", val);
Attr dx(str val) = attr("dx", val);
Attr dy(str val) = attr("dy", val);
Attr edgeMode(str val) = attr("edgeMode", val);
Attr elevation(str val) = attr("elevation", val);
Attr end(str val) = attr("end", val);
Attr exponent(str val) = attr("exponent", val);
Attr externalResourcesRequired(str val) = attr("externalResourcesRequired", val);
Attr filterRes(str val) = attr("filterRes", val);
Attr filterUnits(str val) = attr("filterUnits", val);
Attr format(str val) = attr("format", val);
Attr from(str val) = attr("from", val);
Attr fx(str val) = attr("fx", val);
Attr fy(str val) = attr("fy", val);
Attr g1(str val) = attr("g1", val);
Attr g2(str val) = attr("g2", val);
Attr glyphName(str val) = attr("glyph-name", val);
Attr glyphRef(str val) = attr("glyphRef", val);
Attr gradientTransform(str val) = attr("gradientTransform", val);
Attr gradientUnits(str val) = attr("gradientUnits", val);
Attr hanging(str val) = attr("hanging", val);
Attr height(str val) = attr("height", val);
Attr horizAdvX(str val) = attr("horiz-adv-x", val);
Attr horizOriginX(str val) = attr("horiz-origin-x", val);
Attr horizOriginY(str val) = attr("horiz-origin-y", val);
Attr id(str val) = attr("id", val);
Attr ideographic(str val) = attr("ideographic", val);
Attr in_(str val) = attr("in", val);
Attr in2(str val) = attr("in2", val);
Attr intercept(str val) = attr("intercept", val);
Attr k(str val) = attr("k", val);
Attr k1(str val) = attr("k1", val);
Attr k2(str val) = attr("k2", val);
Attr k3(str val) = attr("k3", val);
Attr k4(str val) = attr("k4", val);
Attr kernelMatrix(str val) = attr("kernelMatrix", val);
Attr kernelUnitLength(str val) = attr("kernelUnitLength", val);
Attr keyPoints(str val) = attr("keyPoints", val);
Attr keySplines(str val) = attr("keySplines", val);
Attr keyTimes(str val) = attr("keyTimes", val);
Attr lang(str val) = attr("lang", val);
Attr lengthAdjust(str val) = attr("lengthAdjust", val);
Attr limitingConeAngle(str val) = attr("limitingConeAngle", val);
Attr local(str val) = attr("local", val);
Attr markerHeight(str val) = attr("markerHeight", val);
Attr markerUnits(str val) = attr("markerUnits", val);
Attr markerWidth(str val) = attr("markerWidth", val);
Attr maskContentUnits(str val) = attr("maskContentUnits", val);
Attr maskUnits(str val) = attr("maskUnits", val);
Attr mathematical(str val) = attr("mathematical", val);
Attr max(str val) = attr("max", val);
Attr media(str val) = attr("media", val);
Attr method(str val) = attr("method", val);
Attr min(str val) = attr("min", val);
Attr mode(str val) = attr("mode", val);
Attr name(str val) = attr("name", val);
Attr numOctaves(str val) = attr("numOctaves", val);
Attr offset(str val) = attr("offset", val);
Attr operator(str val) = attr("operator", val);
Attr order(str val) = attr("order", val);
Attr orient(str val) = attr("orient", val);
Attr orientation(str val) = attr("orientation", val);
Attr origin(str val) = attr("origin", val);
Attr overlinePosition(str val) = attr("overline-position", val);
Attr overlineThickness(str val) = attr("overline-thickness", val);
Attr panose1(str val) = attr("panose-1", val);
Attr path(str val) = attr("path", val);
Attr pathLength(str val) = attr("pathLength", val);
Attr patternContentUnits(str val) = attr("patternContentUnits", val);
Attr patternTransform(str val) = attr("patternTransform", val);
Attr patternUnits(str val) = attr("patternUnits", val);
Attr pointOrder(str val) = attr("point-order", val);
Attr points(str val) = attr("points", val);
Attr pointsAtX(str val) = attr("pointsAtX", val);
Attr pointsAtY(str val) = attr("pointsAtY", val);
Attr pointsAtZ(str val) = attr("pointsAtZ", val);
Attr preserveAlpha(str val) = attr("preserveAlpha", val);
Attr preserveAspectRatio(str val) = attr("preserveAspectRatio", val);
Attr primitiveUnits(str val) = attr("primitiveUnits", val);
Attr r(str val) = attr("r", val);
Attr radius(str val) = attr("radius", val);
Attr refX(str val) = attr("refX", val);
Attr refY(str val) = attr("refY", val);
Attr renderingIntent(str val) = attr("rendering-intent", val);
Attr repeatCount(str val) = attr("repeatCount", val);
Attr repeatDur(str val) = attr("repeatDur", val);
Attr requiredExtensions(str val) = attr("requiredExtensions", val);
Attr requiredFeatures(str val) = attr("requiredFeatures", val);
Attr restart(str val) = attr("restart", val);
Attr result(str val) = attr("result", val);
Attr rotate(str val) = attr("rotate", val);
Attr rx(str val) = attr("rx", val);
Attr ry(str val) = attr("ry", val);
Attr scale(str val) = attr("scale", val);
Attr seed(str val) = attr("seed", val);
Attr slope(str val) = attr("slope", val);
Attr spacing(str val) = attr("spacing", val);
Attr specularConstant(str val) = attr("specularConstant", val);
Attr specularExponent(str val) = attr("specularExponent", val);
Attr speed(str val) = attr("speed", val);
Attr spreadMethod(str val) = attr("spreadMethod", val);
Attr startOffset(str val) = attr("startOffset", val);
Attr stdDeviation(str val) = attr("stdDeviation", val);
Attr stemh(str val) = attr("stemh", val);
Attr stemv(str val) = attr("stemv", val);
Attr stitchTiles(str val) = attr("stitchTiles", val);
Attr strikethroughPosition(str val) = attr("strikethrough-position", val);
Attr strikethroughThickness(str val) = attr("strikethrough-thickness", val);
Attr string(str val) = attr("string", val);
Attr style(str val) = attr("style", val);
Attr surfaceScale(str val) = attr("surfaceScale", val);
Attr systemLanguage(str val) = attr("systemLanguage", val);
Attr tableValues(str val) = attr("tableValues", val);
Attr target(str val) = attr("target", val);
Attr targetX(str val) = attr("targetX", val);
Attr targetY(str val) = attr("targetY", val);
Attr textLength(str val) = attr("textLength", val);
Attr title(str val) = attr("title", val);
Attr to(str val) = attr("to", val);
Attr transform(str val) = attr("transform", val);
Attr type_(str val) = attr("type", val);
Attr u1(str val) = attr("u1", val);
Attr u2(str val) = attr("u2", val);
Attr underlinePosition(str val) = attr("underline-position", val);
Attr underlineThickness(str val) = attr("underline-thickness", val);
Attr unicode(str val) = attr("unicode", val);
Attr unicodeRange(str val) = attr("unicode-range", val);
Attr unitsPerEm(str val) = attr("units-per-em", val);
Attr vAlphabetic(str val) = attr("v-alphabetic", val);
Attr vHanging(str val) = attr("v-hanging", val);
Attr vIdeographic(str val) = attr("v-ideographic", val);
Attr vMathematical(str val) = attr("v-mathematical", val);
Attr values(str val) = attr("values", val);
Attr version(str val) = attr("version", val);
Attr vertAdvY(str val) = attr("vert-adv-y", val);
Attr vertOriginX(str val) = attr("vert-origin-x", val);
Attr vertOriginY(str val) = attr("vert-origin-y", val);
Attr viewBox(str val) = attr("viewBox", val);
Attr viewTarget(str val) = attr("viewTarget", val);
Attr width(str val) = attr("width", val);
Attr widths(str val) = attr("widths", val);
Attr x(str val) = attr("x", val);
Attr xHeight(str val) = attr("x-height", val);
Attr x1(str val) = attr("x1", val);
Attr x2(str val) = attr("x2", val);
Attr xChannelSelector(str val) = attr("xChannelSelector", val);Attr xlinkActuate(str val) = attributeNS("http://www.w3.org/1999/xlink", "xlink:actuate", val);
Attr xlinkArcrole(str val) = attrNS("http://www.w3.org/1999/xlink", "xlink:arcrole", val);
Attr xlinkHref(str val) = attrNS("http://www.w3.org/1999/xlink", "xlink:href", val);
Attr xlinkRole(str val) = attrNS("http://www.w3.org/1999/xlink", "xlink:role", val);
Attr xlinkShow(str val) = attrNS("http://www.w3.org/1999/xlink", "xlink:show", val);
Attr xlinkTitle(str val) = attrNS("http://www.w3.org/1999/xlink", "xlink:title", val);
Attr xlinkType(str val) = attrNS("http://www.w3.org/1999/xlink", "xlink:type", val);
Attr xmlBase(str val) = attrNS("http://www.w3.org/XML/1998/namespace", "xml:base", val);
Attr xmlLang(str val) = attrNS("http://www.w3.org/XML/1998/namespace", "xml:lang", val);
Attr xmlSpace(str val) = attrNS("http://www.w3.org/XML/1998/namespace", "xml:space", val);Attr y(str val) = attr("y", val);
Attr y1(str val) = attr("y1", val);
Attr y2(str val) = attr("y2", val);
Attr yChannelSelector(str val) = attr("yChannelSelector", val);
Attr z(str val) = attr("z", val);
Attr zoomAndPan(str val) = attr("zoomAndPan", val);

// Presentation attributes
Attr alignmentBaseline(str val) = attr("alignment-baseline", val);
Attr baselineShift(str val) = attr("baseline-shift", val);
Attr clipPath(str val) = attr("clip-path", val);
Attr clipRule(str val) = attr("clip-rule", val);
Attr clip(str val) = attr("clip", val);
Attr colorInterpolationFilters(str val) = attr("color-interpolation-filters", val);
Attr colorInterpolation(str val) = attr("color-interpolation", val);
Attr colorProfile(str val) = attr("color-profile", val);
Attr colorRendering(str val) = attr("color-rendering", val);
Attr color(str val) = attr("color", val);
Attr cursor(str val) = attr("cursor", val);
Attr direction(str val) = attr("direction", val);
Attr display(str val) = attr("display", val);
Attr dominantBaseline(str val) = attr("dominant-baseline", val);
Attr enableBackground(str val) = attr("enable-background", val);
Attr fillOpacity(str val) = attr("fill-opacity", val);
Attr fillRule(str val) = attr("fill-rule", val);
Attr fill(str val) = attr("fill", val);
Attr \filter(str val) = attr("filter", val);Attr floodColor(str val) = attr("flood-color", val);
Attr floodOpacity(str val) = attr("flood-opacity", val);
Attr fontFamily(str val) = attr("font-family", val);
Attr fontSizeAdjust(str val) = attr("font-size-adjust", val);
Attr fontSize(str val) = attr("font-size", val);
Attr fontStretch(str val) = attr("font-stretch", val);
Attr fontStyle(str val) = attr("font-style", val);
Attr fontVariant(str val) = attr("font-variant", val);
Attr fontWeight(str val) = attr("font-weight", val);
Attr glyphOrientationHorizontal(str val) = attr("glyph-orientation-horizontal", val);
Attr glyphOrientationVertical(str val) = attr("glyph-orientation-vertical", val);
Attr imageRendering(str val) = attr("image-rendering", val);
Attr kerning(str val) = attr("kerning", val);
Attr letterSpacing(str val) = attr("letter-spacing", val);
Attr lightingColor(str val) = attr("lighting-color", val);
Attr markerEnd(str val) = attr("marker-end", val);
Attr markerMid(str val) = attr("marker-mid", val);
Attr markerStart(str val) = attr("marker-start", val);
Attr mask(str val) = attr("mask", val);
Attr opacity(str val) = attr("opacity", val);
Attr overflow(str val) = attr("overflow", val);
Attr pointerEvents(str val) = attr("pointer-events", val);
Attr shapeRendering(str val) = attr("shape-rendering", val);
Attr stopColor(str val) = attr("stop-color", val);
Attr stopOpacity(str val) = attr("stop-opacity", val);
Attr strokeDasharray(str val) = attr("stroke-dasharray", val);
Attr strokeDashoffset(str val) = attr("stroke-dashoffset", val);
Attr strokeLinecap(str val) = attr("stroke-linecap", val);
Attr strokeLinejoin(str val) = attr("stroke-linejoin", val);
Attr strokeMiterlimit(str val) = attr("stroke-miterlimit", val);
Attr strokeOpacity(str val) = attr("stroke-opacity", val);
Attr strokeWidth(str val) = attr("stroke-width", val);
Attr stroke(str val) = attr("stroke", val);
Attr textAnchor(str val) = attr("text-anchor", val);
Attr textDecoration(str val) = attr("text-decoration", val);
Attr textRendering(str val) = attr("text-rendering", val);
Attr unicodeBidi(str val) = attr("unicode-bidi", val);
Attr visibility(str val) = attr("visibility", val);
Attr wordSpacing(str val) = attr("word-spacing", val);
Attr writingMode(str val) = attr("writing-mode", val);