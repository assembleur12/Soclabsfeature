
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
# Static active response parameters
LOCAL=`dirname $0`
git_repo_folder="/usr/local/signature-base"
yara_file_extenstions=( ".yar" )
yara_rules_list="/usr/local/signature-base/yara_rules_list.yar"

cd $git_repo_folder

git pull https://github.com/Neo23x0/signature-base.git

rm $git_repo_folder/yara/generic_anomalies.yar $git_repo_folder/yara/general_cloaking.yar $git_repo_folder/yara/thor_inverse_matches.yar $git_repo_folder/yara/yara_mixed_ext_vars.yar $git_repo_folder/yara/apt_cobaltstrike.yar $git_repo_folder/yara/apt_tetris.yar $git_repo_folder/yara/gen_susp_js_obfuscatorio.yar $git_repo_folder/yara/configured_vulns_ext_vars.yar $git_repo_folder/yara/gen_webshells_ext_vars.yar $git_repo_folder/yara/gen_fake_amsi_dll.yar $git_repo_folder/yara/yara-rules_vuln_drivers_strict_renamed.yar $git_repo_folder/yara/expl_connectwise_screenconnect_vuln_feb24.yar $git_repo_folder/yara/expl_citrix_netscaler_adc_exploitation_cve_2023_3519.yar $git_repo_folder/yara/gen_mal_3cx_compromise_mar23.yar $git_repo_folder/yara/gen_vcruntime140_dll_sideloading.yar

# Create File with rules to be compiled
if [ ! -f $yara_rules_list ]
then
    echo "Le fichier $yara_rules_list n'existe pas. Création du fichier..."
    touch $yara_rules_list
    echo "Le fichier $yara_rules_list a été créé."
else
    echo "Le fichier $yara_rules_list existe déjà. Suppression du fichier existant..."
    rm $yara_rules_list
    echo "Le fichier $yara_rules_list a été supprimé."
fi

for e in "${yara_file_extenstions[@]}"
do
  for f1 in $( find $git_repo_folder/yara -type f | grep -F $e ); do
    echo "include \"""$f1"\""" >> $yara_rules_list
  done
done

# Compile Yara Rules
/usr/share/yara/yara-4.5.2/yarac $yara_rules_list /usr/local/signature-base/yara_base_ruleset_compiled.yar
IFS=$SAVEIFS

