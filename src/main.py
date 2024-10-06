#pip install fastapi uvicorn
# uvicorn main:app --host 0.0.0.0 --port 8000 --workers 16
# wrk -t12 -c400 -d30s http://localhost:8000/ > fastapi_benchmark.txt

from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def read_root():
    return {"message": "Hello World"}