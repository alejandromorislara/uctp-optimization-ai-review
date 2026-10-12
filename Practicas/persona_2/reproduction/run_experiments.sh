#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOLVER_ROOT="${SOLVER_ROOT:-${SCRIPT_DIR}/work/cb-ctt}"
EASYLOCAL_ROOT="${EASYLOCAL_ROOT:-${SCRIPT_DIR}/work/easylocal-3}"
RESULTS_FILE="${SCRIPT_DIR}/results.csv"
LOG_DIR="${SCRIPT_DIR}/logs"
SOLUTION_DIR="${SCRIPT_DIR}/solutions"
VIRTUAL_TIMEOUT="${VIRTUAL_TIMEOUT:-192}"

mkdir -p "${LOG_DIR}" "${SOLUTION_DIR}" "${SCRIPT_DIR}/work"

if [[ ! -d "${SOLVER_ROOT}/.git" ]]; then
  git clone https://github.com/iolab-uniud/cb-ctt.git "${SOLVER_ROOT}"
fi

if [[ ! -d "${EASYLOCAL_ROOT}/.git" ]]; then
  if ! git clone https://bitbucket.org/satt/easylocal-3.git "${EASYLOCAL_ROOT}"; then
    git clone https://github.com/iolab-uniud/easylocal.git "${EASYLOCAL_ROOT}"
  fi
fi

make -C "${SOLVER_ROOT}/src" EASYLOCAL="${EASYLOCAL_ROOT}"

SOLVER_COMMIT="$(git -C "${SOLVER_ROOT}" rev-parse HEAD)"
EASYLOCAL_COMMIT="$(git -C "${EASYLOCAL_ROOT}" rev-parse HEAD)"
COMPILER="$(g++ --version | head -n 1 | tr ',' ' ')"

HEADER="instance,seed,objective,violations,reported_time_s,wall_time_s,method,virtual_timeout_s,solver_commit,easylocal_commit,compiler,exit_code,log_path,solution_path"
if [[ ! -f "${RESULTS_FILE}" ]] || [[ "${RESET_RESULTS:-0}" == "1" ]]; then
  printf '%s\n' "${HEADER}" > "${RESULTS_FILE}"
fi

instances=(comp01 comp02 comp03 comp04 comp05 comp06 comp07 comp08 comp09 comp10 comp12 comp13 comp14 comp16 comp17 comp18 comp19 comp20 comp21)
seeds=(0 1 2)

for instance in "${instances[@]}"; do
  for seed in "${seeds[@]}"; do
    if awk -F, -v i="${instance}" -v s="${seed}" 'NR > 1 && $1 == i && $2 == s { found=1 } END { exit !found }' "${RESULTS_FILE}"; then
      echo "Omitida ${instance} semilla ${seed}, ya existe en results.csv"
      continue
    fi

    log_rel="logs/${instance}_seed${seed}.log"
    solution_rel="solutions/${instance}_seed${seed}.sol"
    log_file="${SCRIPT_DIR}/${log_rel}"
    solution_file="${SCRIPT_DIR}/${solution_rel}"

    start_ns="$(date +%s%N)"
    set +e
    "${SOLVER_ROOT}/src/ctt.exe" \
      --main::instance "${SOLVER_ROOT}/instances/comp/${instance}.ectt" \
      --main::method BHC-KSA \
      --main::seed "${seed}" \
      --main::output_file "${solution_file}" \
      --main::virtual_timeout "${VIRTUAL_TIMEOUT}" \
      --main::mwd_bias 0.202 \
      --main::critical_course_bias 0.122 \
      --main::critical_course_threshold 3 \
      --main::stability_bias 0.146 \
      --main::swap_bias 0.803 \
      --KSA::start_temperature 5.394 \
      --KSA::min_temperature 0.069 \
      --KSA::cooling_rate 0.988 \
      --KSA::neighbors_accepted_ratio 0.133 \
      > "${log_file}" 2>&1
    exit_code=$?
    set -e
    end_ns="$(date +%s%N)"
    wall_time="$(awk -v a="${start_ns}" -v b="${end_ns}" 'BEGIN { printf "%.6f", (b-a)/1000000000 }')"

    summary="$(tail -n 1 "${log_file}" | tr -d '\r')"
    objective="$(printf '%s\n' "${summary}" | awk -F'; *' '{print $6}')"
    violations="$(printf '%s\n' "${summary}" | awk -F'; *' '{print $5}')"
    reported_time="$(printf '%s\n' "${summary}" | awk -F'; *' '{print $8}')"

    if [[ ! "${objective}" =~ ^[0-9]+$ ]]; then objective=""; fi
    if [[ ! "${violations}" =~ ^[0-9]+$ ]]; then violations=""; fi
    if [[ ! "${reported_time}" =~ ^[0-9]+([.][0-9]+)?$ ]]; then reported_time=""; fi

    printf '%s,%s,%s,%s,%s,%s,BHC-KSA,%s,%s,%s,"%s",%s,%s,%s\n' \
      "${instance}" "${seed}" "${objective}" "${violations}" "${reported_time}" "${wall_time}" \
      "${VIRTUAL_TIMEOUT}" "${SOLVER_COMMIT}" "${EASYLOCAL_COMMIT}" "${COMPILER}" "${exit_code}" \
      "${log_rel}" "${solution_rel}" >> "${RESULTS_FILE}"

    echo "${instance} semilla ${seed}: coste=${objective:-NA}, violaciones=${violations:-NA}, salida=${exit_code}"
  done
done
