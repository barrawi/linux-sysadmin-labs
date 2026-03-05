import fakeredis
import pytest
from app.main import app  # folder app/ find main.py


# reusable set up function
@pytest.fixture
def client():
    # setting up the app to use fake redis
    app.config["TESTING"] = True
    fake_redis = fakeredis.FakeRedis()
    app.config["REDIS_CLIENT"] = fake_redis
    with app.test_client() as client:
        yield client  # create fake http client


def test_json_endpoint(client):
    # test /json endpoint returns the right structure
    response = client.get("/json")
    data = response.get_json()

    assert response.status_code == 200  # not 404, 500, etc
    assert data["app"] == "containerized-webapp"  # sanity chech
    assert data["environment"] == "Development"
    assert "redis_connected" in data
    assert isinstance(data["redis_connected"], bool)
