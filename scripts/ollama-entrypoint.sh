#!/bin/sh

/bin/ollama serve &
OLLAMA_PID=$!

cleanup() {
    kill $OLLAMA_PID 2>/dev/null || true
    wait $OLLAMA_PID 2>/dev/null || true
    exit 0
}

trap cleanup TERM INT

sleep 5

while ! /bin/ollama list > /dev/null 2>&1; do
    if ! kill -0 $OLLAMA_PID 2>/dev/null; then
        exit 1
    fi
    sleep 2
done

if [ -n "$OLLAMA_MODELS" ]; then
    existing_models=$(/bin/ollama list 2>/dev/null | awk 'NR>1 {print $1}' | tr '\n' ' ')
    
    for model in $OLLAMA_MODELS; do
        model=$(echo "$model" | xargs)
        [ -z "$model" ] && continue
        
        model_base=$(echo "$model" | cut -d':' -f1)
        model_exists=0
        
        for existing in $existing_models; do
            existing_base=$(echo "$existing" | cut -d':' -f1)
            [ "$model_base" = "$existing_base" ] && model_exists=1 && break
        done
        
        if [ $model_exists -eq 0 ]; then
            /bin/ollama pull "$model" 2>&1 || true
        fi
    done
fi

wait $OLLAMA_PID
