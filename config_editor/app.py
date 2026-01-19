import os
import yaml
import json
from flask import Flask, render_template, request, jsonify, send_from_directory
from werkzeug.utils import secure_filename

app = Flask(__name__)
app.config['SECRET_KEY'] = 'trendradar-config-editor-secret-key'

# 配置文件路径
CONFIG_DIR = '../config'
CONFIG_FILE = os.path.join(CONFIG_DIR, 'config.yaml')
FREQ_WORDS_FILE = os.path.join(CONFIG_DIR, 'frequency_words.txt')
AI_ANALYSIS_PROMPT_FILE = os.path.join(CONFIG_DIR, 'ai_analysis_prompt.txt')
AI_TRANSLATION_PROMPT_FILE = os.path.join(CONFIG_DIR, 'ai_translation_prompt.txt')

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/config', methods=['GET'])
def get_config():
    try:
        with open(CONFIG_FILE, 'r', encoding='utf-8') as f:
            config_data = yaml.safe_load(f)
        return jsonify({'success': True, 'data': config_data})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

@app.route('/api/config', methods=['POST'])
def save_config():
    try:
        config_data = request.json.get('data', {})
        with open(CONFIG_FILE, 'w', encoding='utf-8') as f:
            yaml.dump(config_data, f, default_flow_style=False, allow_unicode=True, indent=2)
        return jsonify({'success': True, 'message': '配置保存成功'})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

@app.route('/api/frequency_words', methods=['GET'])
def get_frequency_words():
    try:
        with open(FREQ_WORDS_FILE, 'r', encoding='utf-8') as f:
            content = f.read()
        return jsonify({'success': True, 'content': content})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

@app.route('/api/frequency_words', methods=['POST'])
def save_frequency_words():
    try:
        content = request.json.get('content', '')
        with open(FREQ_WORDS_FILE, 'w', encoding='utf-8') as f:
            f.write(content)
        return jsonify({'success': True, 'message': '关键词文件保存成功'})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

@app.route('/api/ai_analysis_prompt', methods=['GET'])
def get_ai_analysis_prompt():
    try:
        with open(AI_ANALYSIS_PROMPT_FILE, 'r', encoding='utf-8') as f:
            content = f.read()
        return jsonify({'success': True, 'content': content})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

@app.route('/api/ai_analysis_prompt', methods=['POST'])
def save_ai_analysis_prompt():
    try:
        content = request.json.get('content', '')
        with open(AI_ANALYSIS_PROMPT_FILE, 'w', encoding='utf-8') as f:
            f.write(content)
        return jsonify({'success': True, 'message': 'AI分析提示词保存成功'})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

@app.route('/api/ai_translation_prompt', methods=['GET'])
def get_ai_translation_prompt():
    try:
        with open(AI_TRANSLATION_PROMPT_FILE, 'r', encoding='utf-8') as f:
            content = f.read()
        return jsonify({'success': True, 'content': content})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

@app.route('/api/ai_translation_prompt', methods=['POST'])
def save_ai_translation_prompt():
    try:
        content = request.json.get('content', '')
        with open(AI_TRANSLATION_PROMPT_FILE, 'w', encoding='utf-8') as f:
            f.write(content)
        return jsonify({'success': True, 'message': 'AI翻译提示词保存成功'})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

# 提供静态文件
@app.route('/static/<path:path>')
def send_static(path):
    return send_from_directory('static', path)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)