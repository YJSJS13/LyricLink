library(networkD3)
library(igraph)
library(htmlwidgets)

# 데이터 불러오기
node_data2 <- read.csv("r_node_update.csv", fileEncoding = "utf-8", stringsAsFactors = FALSE)
edge_data2 <- read.csv("r_edge_update.csv", fileEncoding = "utf-8", stringsAsFactors = FALSE)

str(node_data2)

# igraph 객체 생성
graph <- graph_from_data_frame(d = edge_data2, vertices = node_data2, directed = FALSE)

# 그룹별 색상 지정
groupColors <- c("#FF4654", "#466FFF","#FFB617", "#18E59B","#AD4BDC")
groupLabels <- c("그룹 1", "그룹 2", "그룹 3", "그룹 4", "그룹 5")

# 노드 크기를 연결된 링크 수에 비례하도록 설정
node_data2$size <- degree(graph)

network <- forceNetwork(Links = edge_data2, Nodes = node_data2,
                        Source = 'source', Target = 'target',
                        NodeID = 'name', Group = 'genre', 
                        Nodesize = 'size', opacityNoHover = TRUE, zoom = TRUE, 
                        fontSize = 10, fontFamily = "Pretendard", opacity = 0.9, 
                        linkDistance = 100, charge = -800,
                        colourScale = JS(sprintf("d3.scaleOrdinal().domain(%s).range(%s);", 
                                                 jsonlite::toJSON(unique(node_data2$group)), 
                                                 jsonlite::toJSON(groupColors))))

# 색상별 그룹 정보 추가
legend_elements <- lapply(1:length(groupColors), function(i) {
  list(
    color = groupColors[i],
    label = groupLabels[i],
    shape = "circle"
  )
})

network$x$options$legend <- list(
  title = "그룹 정보",
  position = "bottomright",
  values = legend_elements
)

# 범례 텍스트 색상을 흰색으로 설정
network$x$options$legendStyles <- list(
  textColor = "white"
)

# HTML 파일로 저장
saveWidget(network, 'index.html', selfcontained = FALSE)

# HTML 파일을 읽어들인 후 스타일 추가
html <- readLines("index.html")
css <- "<style>.legend text { fill: white; }</style>"

# head 태그 안에 CSS 추가
html <- gsub("</head>", paste0(css, "</head>"), html)
writeLines(html, con = "index.html")
