#!/usr/bin/env bash
<<HEAD
    SCRIPT: corrige_param_tef_p2k.sh
    AUTHOR: Agápito Rojas (agapito.rojas@lasa.com.br)
    DESCRIPTION: Script para corrigir parametros do TEF em PDVs P2K
    VERSION: 1.0 (13/08/2019)
    HISTORY:
HEAD

## Arquivos de configuracao
paramgs="/p2k/bin/parametrosGeraisSeguranca.properties"
confapi="/p2k/bin/ConfAPITEF.properties"

## Vericando parametrosGeraisSeguranca
ip_ctf=$(awk '/^IP_CTF = / {print $NF}' ${paramgs})
ip_ctf_cont=$(awk '/^IP_CTF_CONTINGENCIA = / {print $NF}' ${paramgs})
porta_ctf=$(awk '/^PORTA_CTF = / {print $NF}' ${paramgs})
porta_ctf_cont=$(awk '/^PORTA_CTF_CONTINGENCIA = / {print $NF}' ${paramgs})

if [[ -n ${ip_ctf} ]]; then
    if [[ "${ip_ctf}" == "79ec08a56543c6d0d9f15a65ed92fd4ee9bbc45f3a0fcadfc92f2808fb916afe077fad08fcbd92b8a756ccff1cc01e2201004ea1a27b4274a7601466fc10bae298e7c651760b20139526221dc15235272220e6ec4c07702b178627addea11f37347fc62c19dc3fba13b0ac67c826c8893fe7371c3cbb3a6c5487eca1e7104733" ]]; then
        echo "IP_CTF OK."
    else
        sed '/^IP_CTF = /s/=.*/= 79ec08a56543c6d0d9f15a65ed92fd4ee9bbc45f3a0fcadfc92f2808fb916afe077fad08fcbd92b8a756ccff1cc01e2201004ea1a27b4274a7601466fc10bae298e7c651760b20139526221dc15235272220e6ec4c07702b178627addea11f37347fc62c19dc3fba13b0ac67c826c8893fe7371c3cbb3a6c5487eca1e7104733/g' -i ${paramgs}
        [[ $? -eq 0 ]] && echo "IP_CTF corrigido." || echo "IP_CTF errado."
    fi
else
    echo "IP_CTF = 79ec08a56543c6d0d9f15a65ed92fd4ee9bbc45f3a0fcadfc92f2808fb916afe077fad08fcbd92b8a756ccff1cc01e2201004ea1a27b4274a7601466fc10bae298e7c651760b20139526221dc15235272220e6ec4c07702b178627addea11f37347fc62c19dc3fba13b0ac67c826c8893fe7371c3cbb3a6c5487eca1e7104733" >>${paramgs}
    [[ $? -eq 0 ]] && echo "IP_CTF adicionado." || echo "IP_CTF não existe."
fi
if [[ -n ${ip_ctf_cont} ]]; then
    if [[ "${ip_ctf_cont}" == "3ab481d8f9c322c6258396c1055b13c8e7c9ae33152004d766c44cb88731c2f093ea3f32dd69067be11147e35cc295a0787953cd29bd2826bd9e0d18a3c91c696de78caaac247cc16b93c5924b4ca136b6b9059aea2a5b446294249d150b09682f48ac59dcf36a909023ca9eeb3827a339363a12781de835a7e63fbcf4938c7e" ]]; then
        echo "IP_CTF_CONTINGENCIA OK"
    else
        sed '/^IP_CTF_CONTINGENCIA = /s/=.*/= 3ab481d8f9c322c6258396c1055b13c8e7c9ae33152004d766c44cb88731c2f093ea3f32dd69067be11147e35cc295a0787953cd29bd2826bd9e0d18a3c91c696de78caaac247cc16b93c5924b4ca136b6b9059aea2a5b446294249d150b09682f48ac59dcf36a909023ca9eeb3827a339363a12781de835a7e63fbcf4938c7e/g' -i ${paramgs}
        [[ $? -eq 0 ]] && echo "IP_CTF_CONTINGENCIA corrigido." || echo "IP_CTF_CONTINGENCIA errado"
    fi
else
    echo "IP_CTF_CONTINGENCIA = 3ab481d8f9c322c6258396c1055b13c8e7c9ae33152004d766c44cb88731c2f093ea3f32dd69067be11147e35cc295a0787953cd29bd2826bd9e0d18a3c91c696de78caaac247cc16b93c5924b4ca136b6b9059aea2a5b446294249d150b09682f48ac59dcf36a909023ca9eeb3827a339363a12781de835a7e63fbcf4938c7e" >>${paramgs}
    [[ $? -eq 0 ]] && echo "IP_CTF_CONTINGENCIA adicionado." || echo "IP_CTF_CONTINGENCIA não existe."
fi
if [[ -n ${porta_ctf} ]]; then
    if [[ "${porta_ctf}" == "52230a1ff836f2b6cdeff3c4eb31626c15fc23dbe69c28b5b4c0d20137f501e8fb4418bff5e193cc6f29fa1d9fcdb552d25abcf27de64b50a503b440b58a9fcbb535a5b1aeb4498b15cd5bdf96a3f5ef9fab38eeb9a50dc035e3891eee5571eb657b34d234167473f31a40d092c14fe3000a854b6a96e03b1182ad37d485e0f6" ]]; then
        echo "PORTA_CTF OK."
    else
        sed '/^PORTA_CTF = /s/=.*/= 52230a1ff836f2b6cdeff3c4eb31626c15fc23dbe69c28b5b4c0d20137f501e8fb4418bff5e193cc6f29fa1d9fcdb552d25abcf27de64b50a503b440b58a9fcbb535a5b1aeb4498b15cd5bdf96a3f5ef9fab38eeb9a50dc035e3891eee5571eb657b34d234167473f31a40d092c14fe3000a854b6a96e03b1182ad37d485e0f6/g' -i ${paramgs}
        [[ $? -eq 0 ]] && echo "PORTA_CTF corrigido." || echo "PORTA_CTF errado."
    fi
else
    echo "PORTA_CTF = 52230a1ff836f2b6cdeff3c4eb31626c15fc23dbe69c28b5b4c0d20137f501e8fb4418bff5e193cc6f29fa1d9fcdb552d25abcf27de64b50a503b440b58a9fcbb535a5b1aeb4498b15cd5bdf96a3f5ef9fab38eeb9a50dc035e3891eee5571eb657b34d234167473f31a40d092c14fe3000a854b6a96e03b1182ad37d485e0f6" >>${paramgs}
    [[ $? -eq 0 ]] && echo "PORTA_CTF adicionado." || echo "PORTA_CTF não existe."
fi
if [[ -n ${porta_ctf_cont} ]]; then
    if [[ "${porta_ctf_cont}" == "8f4dd66b273486a81d26c3009accccfe93162b9729157ab3ac5273b891b4dfb01afc3b98828c5fa9c8e00e95515f74ea4d06b336d2e1452799c9611fd0e2e5243627446ff18e4723c6e5ee71743d61c7565401f7a7289165c2383ea145396ee418ea8d8fa007a2ad79e95f8a14617b6945d51e81b024da3b161568318d531e6e" ]]; then
        echo "PORTA_CTF_CONTINGENCIA OK."
    else
        sed '/^PORTA_CTF_CONTINGENCIA = /s/=.*/= 8f4dd66b273486a81d26c3009accccfe93162b9729157ab3ac5273b891b4dfb01afc3b98828c5fa9c8e00e95515f74ea4d06b336d2e1452799c9611fd0e2e5243627446ff18e4723c6e5ee71743d61c7565401f7a7289165c2383ea145396ee418ea8d8fa007a2ad79e95f8a14617b6945d51e81b024da3b161568318d531e6e/g' -i ${paramgs}
        [[ $? -eq 0 ]] && echo "PORTA_CTF_CONTINGENCIA corrigido." || echo "PORTA_CTF_CONTINGENCIA errado."
    fi
else
    echo "PORTA_CTF_CONTINGENCIA = 8f4dd66b273486a81d26c3009accccfe93162b9729157ab3ac5273b891b4dfb01afc3b98828c5fa9c8e00e95515f74ea4d06b336d2e1452799c9611fd0e2e5243627446ff18e4723c6e5ee71743d61c7565401f7a7289165c2383ea145396ee418ea8d8fa007a2ad79e95f8a14617b6945d51e81b024da3b161568318d531e6e" >>${paramgs}
    [[ $? -eq 0 ]] && echo "PORTA_CTF_CONTINGENCIA adicionado" || echo "PORTA_CTF_CONTINGENCIA não existe."
fi

## Verificando ConfAPITEF
prot_ctf=$(awk '/^PROTOCOLO_CTF = / {print $NF}' ${confapi})
prot_ctf_cont=$(awk '/^PROTOCOLO_CTF_CONTINGENCIA = / {print $NF}' ${confapi})

if [[ -n ${prot_ctf} ]]; then
    if [[ "${prot_ctf}" == "UDP" ]]; then
        echo "PROTOCOLO_CTF OK."
    else
        sed '/^PROTOCOLO_CTF = /s/=.*/= UDP/g' -i ${confapi}
        [[ $? -eq 0 ]] && echo "PROTOCOLO_CTF corrigido." || echo "PROTOCOLO_CTF errado."
    fi
else
    echo "PROTOCOLO_CTF = UDP" >>${confapi}
    [[ $? -eq 0 ]] && echo "PROTOCOLO_CTF adicionado." || echo "PROTOCOLO_CTF não existe."
fi
if [[ -n ${prot_ctf_cont} ]]; then
    if [[ "${prot_ctf_cont}" == "TCP" ]]; then
        echo "PROTOCOLO_CTF_CONTINGENCIA OK."
    else
        sed '/^PROTOCOLO_CTF_CONTINGENCIA = /s/=.*/= TCP/g' -i ${confapi}
        [[ $? -eq 0 ]] && echo "PROTOCOLO_CTF_CONTINGENCIA adicionado." || echo "PROTOCOLO_CTF_CONTINGENCIA errado."
    fi
else
    echo "PROTOCOLO_CTF_CONTINGENCIA = TCP" >>${confapi}
    [[ $? -eq 0 ]] && echo "PROTOCOLO_CTF_CONTINGENCIA adicionado." || echo "PROTOCOLO_CTF_CONTINGENCIA não existe."
fi