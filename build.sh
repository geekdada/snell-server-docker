#!/bin/bash

set -e

VERSION=$1
CHANNEL=${2:-stable} # 默认为 stable 通道

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# 显示使用说明
show_usage() {
  echo "Usage: $0 VERSION [CHANNEL]"
  echo ""
  echo "Parameters:"
  echo "  VERSION  版本号 (必需，例如: 4.0.1, 5.0.0-beta)"
  echo "  CHANNEL  发布通道 (可选，默认: stable)"
  echo ""
  echo "Channels:"
  echo "  stable   正式版发布 - 更新 latest 和对应版本 tag"
  echo "  beta     测试版发布 - 仅发布对应版本的 tag"
  echo ""
  echo "Examples:"
  echo "  $0 4.0.1              # 正式版发布"
  echo "  $0 4.0.1 stable       # 正式版发布"
  echo "  $0 5.0.0-beta beta    # 测试版发布"
}

# 验证参数
if [ -z "$VERSION" ]; then
  print_error "版本号不能为空"
  show_usage
  exit 1
fi

# 检查版本号格式，必须是数字开头
if [[ ! $VERSION =~ ^[0-9]+ ]]; then
  print_error "版本号必须以数字开头，例如: 4.0.1, 5.0.0-beta"
  show_usage
  exit 1
fi

if [ "$CHANNEL" != "stable" ] && [ "$CHANNEL" != "beta" ]; then
  print_error "发布通道必须是 'stable' 或 'beta'"
  show_usage
  exit 1
fi

# 提取大版本号 (例如: 4.0.1 -> 4)
extract_major_version() {
  local version=$1
  if [[ $version =~ ^([0-9]+) ]]; then
    echo "${BASH_REMATCH[1]}"
  else
    print_error "无法从版本号 '$version' 中提取大版本号"
    exit 1
  fi
}

MAJOR_VERSION=$(extract_major_version "$VERSION")
IMAGE_NAME="geekdada/snell-server"

print_info "开始构建 Docker 镜像..."
print_info "版本号: $VERSION"
print_info "发布通道: $CHANNEL"
print_info "大版本号: $MAJOR_VERSION"

# 构建 Docker 镜像
print_info "正在构建镜像..."
docker buildx build \
  --platform linux/amd64 \
  --build-arg BUILDPLATFORM=linux/amd64 \
  --build-arg TARGETPLATFORM=linux/amd64 \
  --build-arg VERSION=${VERSION} \
  --tag ${IMAGE_NAME}:${VERSION} \
  .

print_success "镜像构建完成"

# 准备标签列表
TAGS=("$VERSION")

# 添加大版本标签
TAGS+=("$MAJOR_VERSION")
print_info "添加大版本标签: $MAJOR_VERSION"

# 根据发布通道添加标签
if [ "$CHANNEL" = "stable" ]; then
  TAGS+=("latest")
  print_info "正式版发布，添加 latest 标签"
else
  print_info "测试版发布，跳过 latest 标签"
fi

# 为所有标签创建 Docker tag
print_info "正在创建标签..."
for tag in "${TAGS[@]}"; do
  if [ "$tag" != "$VERSION" ]; then # 跳过已经在构建时创建的版本标签
    docker tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:${tag}
    print_success "创建标签: ${IMAGE_NAME}:${tag}"
  fi
done

# 推送所有标签
print_info "正在推送镜像..."
for tag in "${TAGS[@]}"; do
  print_info "推送标签: ${IMAGE_NAME}:${tag}"
  docker push ${IMAGE_NAME}:${tag}
  print_success "推送完成: ${IMAGE_NAME}:${tag}"
done

print_success "所有操作完成！"
print_info "已推送的标签:"
for tag in "${TAGS[@]}"; do
  echo "  - ${IMAGE_NAME}:${tag}"
done
