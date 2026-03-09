from flask import Flask, request, redirect, render_template, url_for
from flask_sqlalchemy import SQLAlchemy
import random, string, os

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///urls.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

class URL(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    original = db.Column(db.String(2048), nullable=False)
    short_code = db.Column(db.String(10), unique=True, nullable=False)

def generate_code(length=6):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=length))

@app.route('/', methods=['GET', 'POST'])
def index():
    short_url = None
    if request.method == 'POST':
        original_url = request.form['url']
        code = generate_code()
        while URL.query.filter_by(short_code=code).first():
            code = generate_code()
        new_url = URL(original=original_url, short_code=code)
        db.session.add(new_url)
        db.session.commit()
        short_url = request.host_url + code
    return render_template('index.html', short_url=short_url)

@app.route('/<code>')
def redirect_url(code):
    url_entry = URL.query.filter_by(short_code=code).first_or_404()
    return redirect(url_entry.original)

@app.route('/health')
def health():
    return {"status": "healthy"}, 200

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(host='0.0.0.0', port=5000)
