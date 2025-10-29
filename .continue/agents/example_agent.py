import requests
import sseclient
import time

SSE_URL = "http://127.0.0.1:11434/mcp/sse"
POLL_URL = "http://127.0.0.1:11434/api/tags"

def main():
    print(f"Connecting to {SSE_URL}...")
    try:
        response = requests.get(SSE_URL, stream=True, timeout=5)
    except Exception as e:
        print(f"Connection error: {e}")
        return

    if response.status_code != 200:
        print(f"SSE not available (HTTP {response.status_code}), falling back to polling {POLL_URL}")
        # Polling fallback: query /api/tags periodically and print summary
        try:
            while True:
                r = requests.get(POLL_URL, timeout=5)
                if r.status_code == 200:
                    data = r.json()
                    models = data.get('models') if isinstance(data, dict) else None
                    print(f"Polled models: {len(models) if models else 'N/A'}")
                else:
                    print(f"Poll failed: HTTP {r.status_code}")
                time.sleep(5)
        except KeyboardInterrupt:
            return
        except Exception as e:
            print(f"Polling error: {e}")
            return

    client = sseclient.SSEClient(response)
    for event in client.events():
        print(f"Received event: {event.data}")

if __name__ == "__main__":
    main()
