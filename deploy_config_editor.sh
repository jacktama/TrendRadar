#!/bin/bash

# TrendRadar 配置编辑器部署和管理脚本

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函数：打印带颜色的信息
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

# 检查Docker是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker未安装，请先安装Docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose未安装，请先安装Docker Compose"
        exit 1
    fi
    
    print_info "Docker和Docker Compose已安装"
}

# 部署配置编辑器
deploy_config_editor() {
    print_info "开始部署配置编辑器..."
    
    cd docker
    
    # 构建并启动配置编辑器
    docker-compose -f docker-compose-config-editor.yml up -d --build
    
    if [ $? -eq 0 ]; then
        print_success "配置编辑器已成功部署！"
        print_info "访问地址: http://<your-server-ip>:5000"
        print_info "配置编辑器允许您通过Web界面编辑项目的配置文件"
    else
        print_error "配置编辑器部署失败"
        exit 1
    fi
    
    cd ..
}

# 重启TrendRadar服务
restart_trendradar() {
    print_info "正在重启TrendRadar服务..."
    
    # 停止现有服务
    docker-compose -f docker/docker-compose-build.yml down || true
    
    # 启动服务
    docker-compose -f docker/docker-compose-build.yml up -d
    
    if [ $? -eq 0 ]; then
        print_success "TrendRadar服务已成功重启！"
    else
        print_error "TrendRadar服务重启失败"
        exit 1
    fi
}

# 重启配置编辑器
restart_config_editor() {
    print_info "正在重启配置编辑器..."
    
    cd docker
    docker-compose -f docker-compose-config-editor.yml restart
    cd ..
    
    if [ $? -eq 0 ]; then
        print_success "配置编辑器已成功重启！"
    else
        print_error "配置编辑器重启失败"
        exit 1
    fi
}

# 停止配置编辑器
stop_config_editor() {
    print_info "正在停止配置编辑器..."
    
    cd docker
    docker-compose -f docker-compose-config-editor.yml down
    cd ..
    
    print_success "配置编辑器已停止"
}

# 查看服务状态
show_status() {
    print_info "当前容器状态:"
    docker ps | grep -E "(trendradar|config-editor)"
}

# 主菜单
show_menu() {
    echo ""
    echo "==========================================="
    echo "    TrendRadar 配置编辑器部署管理工具"
    echo "==========================================="
    echo "1) 部署配置编辑器"
    echo "2) 重启TrendRadar服务 (修改配置后执行)"
    echo "3) 重启配置编辑器"
    echo "4) 停止配置编辑器"
    echo "5) 查看服务状态"
    echo "6) 退出"
    echo "==========================================="
}

# 主循环
while true; do
    show_menu
    read -p "请选择操作 (1-6): " choice
    
    case $choice in
        1)
            check_docker
            deploy_config_editor
            ;;
        2)
            check_docker
            restart_trendradar
            ;;
        3)
            check_docker
            restart_config_editor
            ;;
        4)
            check_docker
            stop_config_editor
            ;;
        5)
            check_docker
            show_status
            ;;
        6)
            print_info "退出管理工具"
            exit 0
            ;;
        *)
            print_error "无效的选择，请输入1-6之间的数字"
            ;;
    esac
    
    echo ""
    read -p "按任意键继续..."
done