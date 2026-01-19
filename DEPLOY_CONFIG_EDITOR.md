# 在Linux服务器上部署配置编辑器

本文档将指导您如何在Linux服务器上部署配置编辑器，以及如何在修改配置后重启Docker镜像。

## 1. 准备工作

确保您的Linux服务器已安装以下软件：

- Docker
- Docker Compose

### 安装Docker（如果尚未安装）

```bash
# 更新包索引
sudo apt-get update

# 安装必要的包以允许apt通过HTTPS使用仓库
sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release

# 添加Docker官方GPG密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 添加Docker仓库
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 更新包索引并安装Docker
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

# 将当前用户添加到docker组（可选，避免每次使用sudo）
sudo usermod -aG docker $USER
```

### 安装Docker Compose

```bash
# 下载最新版本的Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 添加执行权限
sudo chmod +x /usr/local/bin/docker-compose

# 验证安装
docker-compose --version
```

## 2. 部署配置编辑器

### 方法一：使用部署脚本

1. 将整个TrendRadar项目上传到您的Linux服务器

2. 进入项目目录
```bash
cd /path/to/TrendRadar
```

3. 给部署脚本添加执行权限
```bash
chmod +x deploy_config_editor.sh
```

4. 运行部署脚本
```bash
./deploy_config_editor.sh
```

5. 选择选项 `1` 来部署配置编辑器

### 方法二：手动部署

1. 进入docker目录
```bash
cd docker
```

2. 构建并启动配置编辑器
```bash
docker-compose -f docker-compose-config-editor.yml up -d --build
```

## 3. 访问配置编辑器

部署完成后，您可以通过以下地址访问配置编辑器：
```
http://<your-server-ip>:5000
```

在这里您可以：
- 编辑 `config.yaml` 中的各种配置选项
- 修改 `frequency_words.txt` 关键词文件
- 更新AI分析和翻译的提示词文件

## 4. 修改配置后重启Docker镜像

### 使用部署脚本

1. 运行部署脚本
```bash
./deploy_config_editor.sh
```

2. 选择选项 `2` 来重启TrendRadar服务

### 手动重启

如果您没有使用部署脚本，可以手动重启服务：

1. 停止当前运行的服务
```bash
docker-compose -f docker/docker-compose-build.yml down
```

2. 启动服务（使用新配置）
```bash
docker-compose -f docker/docker-compose-build.yml up -d
```

## 5. 验证部署

### 检查容器状态
```bash
docker ps | grep trendradar
```

您应该能看到正在运行的容器。

### 查看日志
```bash
# 查看TrendRadar服务日志
docker logs trendradar

# 查看MCP服务日志
docker logs trendradar-mcp
```

## 6. 安全注意事项

1. **配置编辑器访问安全**：
   - 配置编辑器允许直接编辑配置文件，应限制其访问权限
   - 考虑使用反向代理（如Nginx）并配置认证
   - 如果不需要，记得停止配置编辑器容器

2. **防火墙配置**：
   - 限制5000端口的访问，仅允许特定IP访问
   ```bash
   # 例如，仅允许来自特定IP的访问
   sudo ufw allow from <your-ip> to any port 5000
   ```

## 7. 常见问题

### Q: 配置编辑器无法访问
A: 检查：
1. 服务器防火墙是否开放了5000端口
2. Docker容器是否正常运行：`docker ps`
3. 服务器提供商的安全组设置（如AWS EC2、阿里云等）

### Q: 修改配置后重启服务失败
A: 检查：
1. 配置文件语法是否正确
2. 日志输出：`docker logs trendradar`
3. 确保配置文件挂载正确

### Q: 如何停止配置编辑器
A: 
```bash
cd docker
docker-compose -f docker-compose-config-editor.yml down
```

## 7. 管理命令速查

| 操作 | 命令 |
|------|------|
| 启动配置编辑器 | `docker-compose -f docker-compose-config-editor.yml up -d --build` |
| 停止配置编辑器 | `docker-compose -f docker-compose-config-editor.yml down` |
| 重启配置编辑器 | `docker-compose -f docker-compose-config-editor.yml restart` |
| 重启TrendRadar服务 | `docker-compose -f docker/docker-compose-build.yml down && docker-compose -f docker/docker-compose-build.yml up -d` |
| 查看所有容器 | `docker ps` |
| 查看容器日志 | `docker logs <container-name>` |

## 8. 工作流程

1. 通过Web界面（端口5000）编辑配置
2. 确认配置无误后，使用脚本或手动重启TrendRadar服务
3. 验证服务正常运行
4. （可选）停止配置编辑器以提高安全性

按照以上步骤，您就可以在Linux服务器上成功部署配置编辑器，并在修改配置后正确重启Docker镜像。