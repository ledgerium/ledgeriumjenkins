# oyente docker container is removed
docker rm -f oyente || true
cd $(pwd)/contracts

chmod +777 *
echo "" >../oyentelogs.txt

# Replacing compiler version 0.5.1 to 0.4.24 in the file to support the solidity compiler version in docker oyente
for file in *; do 
    if [ -f "$file" ]; then 
        echo "$file" 
        sed -i 's/\^//g' $file
        sed -i 's/0.5.1/0.4.24/g' $file
    fi 
done

# Running oyente docker container from jenkins where volume pointed to hostmachine volume
# when docker command is executed from jenkins, it tries to look for the file paths(volume path here) present in host machine.
docker run -d  -it --name oyente -v HOSTPATH/contract_audit_oyente/workspace/contracts:/tmp qspprotocol/oyente-0.4.24

# passing the file name to docker oyente for execution.
for file in *; do 
    if [ -f "$file" ]; then 
        echo "$file" 

        docker exec -t oyente bash -c 'cd /oyente/oyente && python oyente.py -s /tmp/'$file >> ../logs.txt 2>&1 || true

    fi 
done

# Removing oyente container once the process is done
docker rm -f oyente || true
        
#echo "" > $(docker inspect --format='{{.LogPath}}' oyente)

echo "oyente reports are generated"
