"""
Small App to run a web page in order to practice containerization
Wilberth Barrantes Calderon
"""

import os
import platform
import socket
from datetime import datetime

import redis
from flask import Flask, jsonify, render_template

app = Flask(__name__)  # looks for resources

# redis connection
cache = redis.Redis(
    host=os.getenv("REDIS_HOST", "cache"), port=6379, socket_timeout=2
)  # socket on 2 so it doesnt hang trying to connect


@app.route("/")  # when someone visits, run function bellow
def index():
    # will fetch metadata to verify the container is dynamic
    metadata = {
        "hostname": socket.gethostname(),
        "ip_address": socket.gethostbyname(socket.gethostname()),
        "environment": os.getenv("APP_ENV", "Development"),
        "debug_mode": os.getenv("APP_DEBUG", "False"),
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    }
    return render_template("index.html", data=metadata)


@app.route("/json")
def get_json():
    # to check redis status
    try:
        redis_up = cache.ping()
    except Exception:
        redis_up = False

    # return a json with specific format
    return jsonify(
        {
            "app": "containerized-webapp",
            "version": "1.0.0",
            "enviroment": os.getenv("APP_ENV", "Development"),
            "hostname": socket.gethostname(),
            "timestamp": datetime.now().isoformat(),
            "python_version": platform.python_version(),
            "redis_connected": redis_up,
        }
    )


@app.route("/health")
def health_check():
    return {"status": "healthy"}, 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)  # all interfaces inside the container
