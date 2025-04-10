#!/bin/bash -e

# Precheck required environment variable TF_VAR_libvirt_uris
# export TF_VAR_libvirt_uris='["qemu:///system", "qemu+ssh://user@localhost/system"]'
if [ ! -n "$TF_VAR_libvirt_uris" ]; then
    echo "ERROR: Environment Variable \"TF_VAR_libvirt_uris\" not found!" >&2
    exit 1
fi

# Extract the value of TF_VAR_libvirt_uris
uri_string="${TF_VAR_libvirt_uris//[\[\]\"]/}"

# Split the string into an array
IFS=',' read -ra uri_array <<< "$uri_string"

# Trim leading and trailing whitespace from each element
for i in "${!uri_array[@]}"; do
    uri_array[$i]=$(echo "${uri_array[$i]}" | xargs)
done

# Build json data
json_array_elements=""
for uri in "${uri_array[@]}"; do
    if [ -n "$json_array_elements" ]; then
        json_array_elements="$json_array_elements, \"$uri\""
    else
        json_array_elements="\"$uri\""
    fi
done
# Construct json data
json_data="{\"libvirt_uris\": [$json_array_elements], \"libvirt_uris_length\": ${#uri_array[@]}}"

# Write to temp file
echo "${json_data}" | tee /tmp/data.json > /dev/null 2>&1

# Render template
j2 main.tf.j2 /tmp/data.json -o main.tf

# Terraform init to install dynamic provider
terraform init
