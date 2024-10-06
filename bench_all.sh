#!/opt/homebrew/bin/bash # Change this to your shell path must be >= than 4.0

# Check if a workers argument is provided
if [ -z "$1" ]; then
  echo "Usage: ./bench_all.sh <number_of_workers>"
  exit 1
fi

WORKERS=$1
echo "Using $WORKERS workers for each server."

# Ensure results directory exists
mkdir -p benchmark_results

# Function to install/setup each framework
install_dependencies() {
  app_name=$1
  echo "Installing dependencies for $app_name..."

  case "$app_name" in
    "express")
      # Install Node.js and Express dependencies
      if ! [ -x "$(command -v node)" ]; then
        echo "Node.js not found. Installing Node.js..."
        brew install node
      fi
      npm install
      ;;

    "fastapi")
      # Install Python dependencies
      if ! [ -x "$(command -v python3)" ]; then
        echo "Python not found. Installing Python..."
        brew install python3
      fi
      if ! [ -x "$(command -v pip)" ]; then
        echo "pip not found. Installing pip..."
        python3 -m ensurepip --upgrade
      fi
      pip install fastapi uvicorn
      ;;

    "go")
      # Install Go if not installed
      if ! [ -x "$(command -v go)" ]; then
        echo "Go not found. Installing Go..."
        brew install go
      fi
      ;;

    "rust")
      # Install Rust and cargo if not installed
      if ! [ -x "$(command -v cargo)" ]; then
        echo "Rust not found. Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
      fi
      cargo build
      ;;

    *)
      echo "Unknown app: $app_name"
      exit 1
      ;;
  esac
}

# Display the benchmark results by reading saved files and sorting by performance
display_benchmark_results() {
  declare -a results_array

  # Function to extract relevant results from wrk output files
  parse_benchmark_results_from_file() {
    app_name=$1
    wrk_output_file="benchmark_results/${app_name}_benchmark.txt"

    if [[ -f "$wrk_output_file" ]]; then    
      # Extract 'Requests/sec' from the 'Requests/sec:' line
      requests_per_sec=$(grep "Requests/sec:" "$wrk_output_file" | awk '{print $2}')
      
      # Extract 'Latency' (average latency from the 'Latency' line)
      latency=$(grep "Latency" "$wrk_output_file" | head -n 1 | awk '{print $2}')

      # Extract 'Transfer/sec' from the 'Transfer/sec:' line
      transfer_rate=$(grep "Transfer/sec:" "$wrk_output_file" | awk '{print $2 " " $3}')

      # Append the result to an array for sorting later
      results_array+=("$requests_per_sec $app_name $latency $transfer_rate")

      # # Debug: Print out parsed values to check if they're correct
      # echo "Parsed values for $app_name:"
      # echo "Requests/sec: $requests_per_sec"
      # echo "Latency: $latency"
      # echo "Transfer/sec: $transfer_rate"
    else
      echo "Error: Benchmark file for $app_name not found at $wrk_output_file"
    fi
  }

  # Parse results for each app
  for app in "${!apps[@]}"; do
    parse_benchmark_results_from_file "$app"
  done

  # Sort results by requests/sec in descending order
  sorted_results=$(printf "%s\n" "${results_array[@]}" | sort -nr)

  # Display sorted results
  echo -e "\n====== Benchmark Results (Sorted by Performance) ======"
  printf "%-15s %-20s %-15s %-20s\n" "App" "Requests/sec" "Latency" "Transfer/sec"
  echo "-------------------------------------------------------------"

  while IFS= read -r line; do
    set -- $line
    printf "%-15s %-20s %-15s %-20s\n" "$2" "$1" "$3" "$4"
  done <<< "$sorted_results"

  echo "============================================================="
}

# Function to kill any process using port 8000
cleanup_port() {
  echo "Cleaning up any process using port 8000..."
  port_pid=$(lsof -ti:8000)
  if [ ! -z "$port_pid" ]; then
    echo "Killing process $port_pid using port 8000..."
    kill -9 $port_pid
  fi
}

# Function to run the benchmark and save to file
run_benchmark() {
  app_name=$1
  start_cmd=$2

  # Install dependencies for the app
  install_dependencies "$app_name"

  # Start the server in the background
  echo "Starting $app_name server with $WORKERS workers..."
  eval "$start_cmd &"
  server_pid=$!

  # Give the server time to start up
  sleep 2

  # Run the benchmark and write output to a file
  echo "Running benchmark for $app_name..."
  wrk -t12 -c400 -d30s http://localhost:8000/ > "benchmark_results/${app_name}_benchmark.txt"

  # Stop the server
  echo "Stopping $app_name server..."
  kill $server_pid

  # Make sure nothing is still running on port 8000
  cleanup_port

  # Ensure the server is stopped before moving to the next one
  wait $server_pid 2>/dev/null

  # Give a short pause before the next test
  sleep 2
}

# Define an array of server types and their corresponding file extensions
declare -A apps
apps=(
  ["express"]="WORKERS=$WORKERS node src/main.js"         # Node.js Express
  ["fastapi"]="WORKERS=$WORKERS uvicorn src.main:app --host 0.0.0.0 --port 8000 --workers $WORKERS"  # FastAPI
  ["go"]="WORKERS=$WORKERS go run src/main.go"            # Go HTTP server (if using custom worker control)
  ["rust"]="WORKERS=$WORKERS cargo run"  # Rust Actix Web server
)

# Ensure no process is using port 8000 before starting
cleanup_port

# Iterate through each app, run its benchmark, and save results
for app in "${!apps[@]}"; do
  run_benchmark "$app" "${apps[$app]}"
done

echo "All benchmarks completed. Results saved in benchmark_results/ directory."

# Display the benchmark results
display_benchmark_results