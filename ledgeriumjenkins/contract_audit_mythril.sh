# Removing any existing mythril container
docker rm -f mythril || true
cd $(pwd)/contracts
chmod +777 *
# Replacing 0.5.1 compiler version to 0.5.0 for each file as the mythril docker supports 0.5.0
for file in *; do 
    if [ -f "$file" ]; then 
        echo "$file" 
        sed -i 's/\^//g' $file
        sed -i 's/0.5.1/0.5.0/g' $file
    fi 
done
        
# Looping each file from jenkins workspace and executing the mythril docker pointing to the file present in hostmachine jenkinshome and mythril docker is removed.
# when docker command is executed from jenkins, it tries to look for the file paths(volume path here) present in host machine.

for file in *; do 
    if [ -f "$file" ]; then 
        echo "****$file****" >> ../logs.txt
        docker run --name mythril -v HOSTPATH/contract_audit_mythril/workspace/contracts:/tmp mythril/myth -x /tmp/"$file" || true
        
        docker logs mythril >> ../logs.txt || true
        
        docker rm -f mythril || true
    fi 
done

echo "Process Done"
