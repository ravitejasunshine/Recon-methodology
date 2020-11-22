#!/bin/bash

domain=$1
wordlist="/root/tools/SecLists/Discovery/DNS/deepmagic.com-prefixes-top500.txt"
resolvers="/root/resolvers.txt"

domain_enum(){
	
mkdir -p $domain $domain/sources $domain/Recon $domain/Recon/nuclei $domain/Recon/wayback 

subfinder -d $domain -o  $domain/sources/subfinder.txt
assetfinder -subs-only $domain | tee $domain/sources/hackerone.com
amass enum -passive -d $domain -o $domain/sources/passive.txt
shuffledns -d $domain -w $wordlist -r $resolvers -o shuffledns.txt

cat $domain/sources/.*txt > $domain /sources/all.txt
}
domain_enum

resloving_domains(){
shuffledns -d $domain -list $domain/sources/all.txt -o $domain/domains.txt -r $resolvers	
}
resolving_domains

http_prob(){
cat $domain/domains.txt | httpx -threads 200 -o $domain/Recon/httpx.txt
}
http_prob

scanner(){

cat $domain/Recon/httpx.txt | nuclei -t /root/nuclei-templates/cves/ -c 50 -o $domain/Recon/nuclei/cve.txt
cat $domain/Recon/httpx.txt | nuclei -t /root/nuclei-templates/vulnerabilities/ -c 50 -o $domain/Recon/nuclei/vulnerabilities.txt
cat $domain/Recon/httpx.txt | nuclei -t /root/nuclei-templates/files/ -c 50 -o $domain/Recon/nuclei/files.txt

}
scanner

wayback_data(){

cat $domain/domains.txt | waybackurls | tee $domain/Recon/wayback/tmp.txt	

}
wayback_data

