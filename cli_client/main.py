import os
import sys
import json
import httpx

# Реальный URL API. Благодаря вашему файлу hosts, запрос к этому домену 
# будет автоматически перенаправлен на ваш SNI-прокси 
API_URL = "https://api.openai.com/v1/chat/completions"

def get_api_key():
    """Безопасное получение API ключа из переменных окружения."""
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        print("❌ Ошибка: Не найден API-ключ.")
        print("💡 Решение: Установите переменную окружения OPENAI_API_KEY")
        print("   или создайте файл '.env' в папке cli_client с содержимым: OPENAI_API_KEY=ваш_ключ")
        sys.exit(1)
    return api_key

def main():
    print("=" * 50)
    print(" 🤖 Терминальный ИИ-клиент (LikeProxy)")
    print(" Введите 'exit' или 'quit' для завершения.")
    print("=" * 50)
    
    api_key = get_api_key()
    
    # Настраиваем клиент с таймаутом, чтобы не зависать при сетевых сбоях
    client = httpx.Client(timeout=30.0)

    try:
        while True:
            user_prompt = input("\n👤 Вы: ").strip()
            if user_prompt.lower() in ['exit', 'quit', 'выход']:
                print("👋 Завершение работы...")
                break
            if not user_prompt:
                continue

            payload = {
                "model": "gpt-3.5-turbo", # Можно заменить на gpt-4o или другую доступную модель
                "messages": [{"role": "user", "content": user_prompt}],
                "stream": True # Включаем потоковую передачу для CLI
            }
            
            headers = {
                "Authorization": f"Bearer {api_key}",
                "Content-Type": "application/json"
            }

            print("🤖 ИИ: ", end="", flush=True)
            
            try:
                # Запрос отправляется на api.openai.com, но ОС перенаправит его на ваш прокси
                with client.stream("POST", API_URL, json=payload, headers=headers) as response:
                    response.raise_for_status()
                    
                    # Обработка потока Server-Sent Events (SSE)
                    for line in response.iter_lines():
                        if line.startswith("data: "):
                            data_str = line[6:] # Убираем префикс "data: "
                            if data_str.strip() == "[DONE]":
                                break
                            
                            try:
                                data_json = json.loads(data_str)
                                # Извлечение текста из дельты ответа
                                content = data_json["choices"][0]["delta"].get("content", "")
                                if content:
                                    print(content, end="", flush=True)
                            except json.JSONDecodeError:
                                continue
                print("\n") # Перенос строки после завершения ответа
                
            except httpx.HTTPStatusError as e:
                print(f"\n❌ [Ошибка HTTP] {e.response.status_code}: {e.response.text}")
            except httpx.RequestError as e:
                print(f"\n❌ [Сетевая ошибка] Не удалось соединиться с сервером.")
                print(f"💡 Проверьте, применен ли файл hosts и доступен ли прокси-сервер.")
                print(f"   Детали: {e}")

    except KeyboardInterrupt:
        print("\n👋 Завершение работы по нажатию Ctrl+C...")
    finally:
        client.close()

if __name__ == "__main__":
    main()