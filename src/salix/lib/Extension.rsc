module salix::lib::Extension


alias Extension = tuple[str name, list[Asset] assets];

data Asset
  = css(str url)
  | js(str url)
  ;