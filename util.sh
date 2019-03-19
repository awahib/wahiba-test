
DEFAULT_IMAGE="chat_test"
DEFAULT_FILE="Dockerfile"

SERVICE="chat"

DTR_LOC="ktydkrdtr.eogresources.com/devops"

WORKDIR="."

build_image() {
    diname="${1}" # Docker Image Name
    dfile="${2}"  # Docker File Name

    docker build -t local/"${diname}" --file "${WORKDIR}"/"${dfile}" "${WORKDIR}"
}

push_image() {
    diname="${1}" # Docker Image Name

    # Tag for DTR
    docker tag local/"${diname}" "${DTR_LOC}/${diname}"

    # Push to DTR
    docker push "${DTR_LOC}/${diname}"
}

deploy_stack() {
    # Send Compose file to Manager
    rsync -e "ssh -o StrictHostKeyChecking=no" -av docker-compose.yml dev_deploy@opscntrdev01.eogresources.com:docker-compose.yml

    # Check if service is running 
    local rs="$(ssh -o StrictHostKeyChecking=no dev_deploy@opscntrdev01.eogresources.com docker stack ps ${SERVICE} | grep 'Running')"

    # If no stack has been deployed deploy it.
    #if [ -z "${rs}" ]; then
    # Stack Deploy Chat
    ssh -o StrictHostKeyChecking=no dev_deploy@opscntrdev01.eogresources.com docker stack deploy -c docker-compose.yml ${SERVICE}
    #else
    #   echo "Update it"
    #fi
}


main() {
    while getopts ":bpd" opt; do
        case $opt in
            b)
                build_image "${DEFAULT_IMAGE}" "${DEFAULT_FILE}"
                ;;
            p)
                push_image "${DEFAULT_IMAGE}"
                ;;
            d) 
                deploy_stack
                ;;
            *)
                echo Not Valid Option
                exit 1
                ;;
        esac
    done

    exit $?
}

main "$@"
