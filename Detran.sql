Códigos em SQL Grupo E
#Dados agrupados por UF:
SELECT count(automovel),
sigla_uf 
FROM `koru-dados-417611.AnaliseDenatran.TFrota_UF` Dados
Group By sigla_uf
#Mais cresceram frota total:
SELECT
    sigla_uf,
    ano,
    total_veiculos_janeiro,
    total_veiculos_dezembro,
    total_veiculos_dezembro - total_veiculos_janeiro AS crescimento
FROM
    (
        SELECT
            sigla_uf,
            ano,
            FIRST_VALUE(total_veiculos) OVER (PARTITION BY sigla_uf, ano ORDER BY mes) AS total_veiculos_janeiro,
            LAST_VALUE(total_veiculos) OVER (PARTITION BY sigla_uf, ano ORDER BY mes) AS total_veiculos_dezembro
        FROM
            (
                SELECT
                    sigla_uf,
                    ano,
                    mes,
                    SUM(quantidade) AS total_veiculos
                FROM
                    `basedosdados.br_denatran_frota.uf_tipo`
                WHERE
                    ano BETWEEN 2004 AND 2021
                GROUP BY
                    sigla_uf, ano, mes
            ) AS subconsulta
    ) AS subconsulta2
ORDER BY
    crescimento DESC, sigla_uf, ano;
#Percentual região:
--Pesquisa percentual por regiao com base na consulta https://console.cloud.google.com/bigquery?ws=!1m7!1m6!12m5!1m3!1skoru-dados-417611!2sus-central1!3s9022b408-ead6-430f-aabf-4f0eda3210ed!2e1 - PARTE Cris
SELECT * FROM `koru-dados-417611.AnaliseDenatran.TDadosDenatran` LIMIT 1000;
SELECT 
     CASE 
        WHEN sigla_uf IN ('AC', 'AP', 'AM', 'PA', 'RO', 'RR', 'TO') THEN 'Região Norte'
        WHEN sigla_uf IN ('AL', 'BA', 'CE', 'MA', 'PB', 'PE', 'PI', 'RN', 'SE') THEN 'Região Nordeste'
        WHEN sigla_uf IN ('DF', 'GO', 'MT', 'MS') THEN 'Região Centro-Oeste'
        WHEN sigla_uf IN ('ES', 'MG', 'RJ', 'SP') THEN 'Região Sudeste'
        WHEN sigla_uf IN ('PR', 'RS', 'SC') THEN 'Região Sul'
    END AS regiao,
    SUM(CASE WHEN tipo_veiculo = 'automovel' THEN quantidade ELSE 0 END) AS Carro,
    SUM(CASE WHEN tipo_veiculo = 'caminhao' THEN quantidade ELSE 0 END) AS Caminhao,
    SUM(CASE WHEN tipo_veiculo IN ('onibus', 'micro-onibus') THEN quantidade ELSE 0 END) AS Onibus,
    SUM(CASE WHEN tipo_veiculo IN ('caminhonete', 'utilitario') THEN quantidade ELSE 0 END) AS SUV,
    SUM(CASE WHEN tipo_veiculo IN ('trator rodas', 'trator esteiras', 'caminhao trator') THEN quantidade ELSE 0 END) AS Trator,
    SUM(CASE WHEN tipo_veiculo IN ('triciculo', 'motoneta', 'quadriciclo', 'side-car', 'motocicleta') THEN quantidade ELSE 0 END) AS Motos,
    SUM(CASE WHEN tipo_veiculo IN ('outros', 'reboque', 'chassi_plataforma', 'semi-reboque', 'bonde') THEN quantidade ELSE 0 END) AS Outros,
    SUM(quantidade) AS Total_Veiculos,
    ROUND(SUM(CASE WHEN tipo_veiculo = 'automovel' THEN quantidade ELSE 0 END) / SUM(quantidade) * 100, 2) AS Percentual_Carro,
    ROUND(SUM(CASE WHEN tipo_veiculo = 'caminhao' THEN quantidade ELSE 0 END) / SUM(quantidade) * 100, 2) AS Percentual_Caminhao,
    ROUND(SUM(CASE WHEN tipo_veiculo IN ('onibus', 'micro-onibus') THEN quantidade ELSE 0 END) / SUM(quantidade) * 100, 2) AS Percentual_Onibus,
    ROUND(SUM(CASE WHEN tipo_veiculo IN ('caminhonete', 'utilitario') THEN quantidade ELSE 0 END) / SUM(quantidade) * 100, 2) AS Percentual_SUV,
    ROUND(SUM(CASE WHEN tipo_veiculo IN ('trator rodas', 'trator esteiras', 'caminhao trator') THEN quantidade ELSE 0 END) / SUM(quantidade) * 100, 2) AS Percentual_Trator,
    ROUND(SUM(CASE WHEN tipo_veiculo IN ('triciculo', 'motoneta', 'quadriciclo', 'side-car', 'motocicleta') THEN quantidade ELSE 0 END) / SUM(quantidade) * 100, 2) AS Percentual_Motos,
    ROUND(SUM(CASE WHEN tipo_veiculo IN ('outros', 'reboque', 'chassi_plataforma', 'semi-reboque', 'bonde') THEN quantidade ELSE 0 END) / SUM(quantidade) * 100, 2) AS Percentual_Outros
FROM
    basedosdados.br_denatran_frota.municipio_tipo 
GROUP BY 
    regiao
ORDER BY 
    regiao DESC;
#População >=18 em cada região:
SELECT 
    CASE 
        WHEN sigla_uf IN ('AC', 'AP', 'AM', 'PA', 'RO', 'RR', 'TO') THEN 'Região Norte'
        WHEN sigla_uf IN ('AL', 'BA', 'CE', 'MA', 'PB', 'PE', 'PI', 'RN', 'SE') THEN 'Região Nordeste'
        WHEN sigla_uf IN ('DF', 'GO', 'MT', 'MS') THEN 'Região Centro-Oeste'
        WHEN sigla_uf IN ('ES', 'MG', 'RJ', 'SP') THEN 'Região Sudeste'
        WHEN sigla_uf IN ('PR', 'RS', 'SC') THEN 'Região Sul'
    END AS regiao,
    SUM(populacao) AS populacao
FROM 
    `basedosdados.br_ibge_censo_2022.populacao_grupo_idade_uf`
where grupo_idade not in ('0 a 4', '5 a 9', '10 a 14','15 a 17','15 a 19')
GROUP BY 
    regiao
ORDER BY populacao DESC
#Questão 5.1
SELECT 
    CASE 
        WHEN sigla_uf IN ('AC', 'AP', 'AM', 'PA', 'RO', 'RR', 'TO') THEN 'Região Norte'
        WHEN sigla_uf IN ('AL', 'BA', 'CE', 'MA', 'PB', 'PE', 'PI', 'RN', 'SE') THEN 'Região Nordeste'
        WHEN sigla_uf IN ('DF', 'GO', 'MT', 'MS') THEN 'Região Centro-Oeste'
        WHEN sigla_uf IN ('ES', 'MG', 'RJ', 'SP') THEN 'Região Sudeste'
        WHEN sigla_uf IN ('PR', 'RS', 'SC') THEN 'Região Sul'
    END AS regiao,
    SUM(quantidade) AS total_veiculos
FROM 
    `basedosdados.br_denatran_frota.uf_tipo`
where ano= 2022
GROUP BY regiao
ORDER BY total_veiculos desc
#Questão 5.2
SELECT sigla_uf, 
       SUM(quantidade) AS total 
FROM `basedosdados.br_denatran_frota.uf_tipo`
GROUP BY sigla_uf
ORDER BY total
#Questão 5.3.3
--SELECT  FROM `basedosdados.br_ibge_censo_demografico.microdados_pessoa_2010` LIMIT 100
--renda media em 2022, usamos o de 2010 e corrigimos para 2022
SELECT 
    CASE 
        WHEN sigla_uf IN ('AC', 'AP', 'AM', 'PA', 'RO', 'RR', 'TO') THEN 'Região Norte'
        WHEN sigla_uf IN ('AL', 'BA', 'CE', 'MA', 'PB', 'PE', 'PI', 'RN', 'SE') THEN 'Região Nordeste'
        WHEN sigla_uf IN ('DF', 'GO', 'MT', 'MS') THEN 'Região Centro-Oeste'
        WHEN sigla_uf IN ('ES', 'MG', 'RJ', 'SP') THEN 'Região Sudeste'
        WHEN sigla_uf IN ('PR', 'RS', 'SC') THEN 'Região Sul'
    END AS regiao,
    round(AVG(v6511*2.0597),2) AS renda_media
FROM 
    `basedosdados.br_ibge_censo_demografico.microdados_pessoa_2010`
GROUP BY 
    regiao
ORDER BY renda_media desc
#Select ordenação quem mais cresceu
SELECT
    tipo_veiculo,
    sigla_uf,
    ano,
    total_veiculos_janeiro,
    total_veiculos_dezembro,
    total_veiculos_dezembro - total_veiculos_janeiro AS crescimento
FROM
    (
        SELECT
            tipo_veiculo,
            sigla_uf,
            ano,
            FIRST_VALUE(total_veiculos) OVER (PARTITION BY tipo_veiculo, sigla_uf, ano ORDER BY mes) AS total_veiculos_janeiro,
            LAST_VALUE(total_veiculos) OVER (PARTITION BY tipo_veiculo, sigla_uf, ano ORDER BY mes) AS total_veiculos_dezembro
        FROM
            (
                SELECT
                    tipo_veiculo,
                    sigla_uf,
                    ano,
                    mes,
                    SUM(quantidade) AS total_veiculos
                FROM
                    `basedosdados.br_denatran_frota.uf_tipo`
                WHERE
                    ano BETWEEN 2004 AND 2021
                GROUP BY
                    tipo_veiculo, sigla_uf, ano, mes
            ) AS subconsulta
    ) AS subconsulta2
ORDER BY
    crescimento DESC, tipo_veiculo, sigla_uf, ano;
#Veiculos por região
/*-- Quais são as regiões geográficas e estados com maior concentração de veículos? Quais possuem menos? E quais particularidades podem ser percebidas nessas regiões?*/
SELECT 
    CASE 
        WHEN sigla_uf IN ('AC', 'AP', 'AM', 'PA', 'RO', 'RR', 'TO') THEN 'Região Norte'
        WHEN sigla_uf IN ('AL', 'BA', 'CE', 'MA', 'PB', 'PE', 'PI', 'RN', 'SE') THEN 'Região Nordeste'
        WHEN sigla_uf IN ('DF', 'GO', 'MT', 'MS') THEN 'Região Centro-Oeste'
        WHEN sigla_uf IN ('ES', 'MG', 'RJ', 'SP') THEN 'Região Sudeste'
        WHEN sigla_uf IN ('PR', 'RS', 'SC') THEN 'Região Sul'
    END AS regiao,
    SUM(quantidade) AS total_veiculos
FROM 
    `basedosdados.br_denatran_frota.uf_tipo`
where ano= 2022
GROUP BY regiao
ORDER BY total_veiculos desc
#Automóveis por tipo e região
SELECT 
    CASE 
        WHEN sigla_uf IN ('AC', 'AP', 'AM', 'PA', 'RO', 'RR', 'TO') THEN 'Região Norte'
        WHEN sigla_uf IN ('AL', 'BA', 'CE', 'MA', 'PB', 'PE', 'PI', 'RN', 'SE') THEN 'Região Nordeste'
        WHEN sigla_uf IN ('DF', 'GO', 'MT', 'MS') THEN 'Região Centro-Oeste'
        WHEN sigla_uf IN ('ES', 'MG', 'RJ', 'SP') THEN 'Região Sudeste'
        WHEN sigla_uf IN ('PR', 'RS', 'SC') THEN 'Região Sul'
    END AS regiao,
    SUM(CASE WHEN tipo_veiculo = 'automovel' THEN quantidade ELSE 0 END) AS Carro,
    SUM(CASE WHEN tipo_veiculo = 'caminhao' THEN quantidade ELSE 0 END) AS Caminhao,
    SUM(CASE WHEN tipo_veiculo IN ('onibus', 'micro-onibus') THEN quantidade ELSE 0 END) AS Onibus,
    SUM(CASE WHEN tipo_veiculo IN ('caminhonete', 'utilitario') THEN quantidade ELSE 0 END) AS SUV,
    SUM(CASE WHEN tipo_veiculo IN ('trator rodas', 'trator esteiras', 'caminhao trator') THEN quantidade ELSE 0 END) AS Trator,
    SUM(CASE WHEN tipo_veiculo IN ('triciculo', 'motoneta', 'quadriciclo', 'side-car', 'motocicleta') THEN quantidade ELSE 0 END) AS Motos,
    SUM(CASE WHEN tipo_veiculo IN ('outros', 'reboque', 'chassi_plataforma', 'semi-reboque', 'bonde') THEN quantidade ELSE 0 END) AS Outros
FROM
    basedosdados.br_denatran_frota.municipio_tipo where ano = 2023
GROUP BY 
    regiao
ORDER BY 
    regiao DESC;
#Automóveis por tipo e região (carros, motos e SUV's)
SELECT 
    CASE 
        WHEN sigla_uf IN ('AC', 'AP', 'AM', 'PA', 'RO', 'RR', 'TO') THEN 'Região Norte'
        WHEN sigla_uf IN ('AL', 'BA', 'CE', 'MA', 'PB', 'PE', 'PI', 'RN', 'SE') THEN 'Região Nordeste'
        WHEN sigla_uf IN ('DF', 'GO', 'MT', 'MS') THEN 'Região Centro-Oeste'
        WHEN sigla_uf IN ('ES', 'MG', 'RJ', 'SP') THEN 'Região Sudeste'
        WHEN sigla_uf IN ('PR', 'RS', 'SC') THEN 'Região Sul'
    END AS regiao,
    SUM(CASE WHEN tipo_veiculo = 'automovel' THEN quantidade ELSE 0 END) AS Carro,
    SUM(CASE WHEN tipo_veiculo IN ('caminhonete', 'utilitario') THEN quantidade ELSE 0 END) AS SUV,
    SUM(CASE WHEN tipo_veiculo IN ('triciculo', 'motoneta', 'quadriciclo', 'side-car', 'motocicleta') THEN quantidade ELSE 0 END) AS Motos
FROM
    basedosdados.br_denatran_frota.municipio_tipo where ano = 2022
GROUP BY 
    regiao
ORDER BY 
    regiao DESC;
#Automóveis por tipo e região em 2022
SELECT 
    CASE 
        WHEN sigla_uf IN ('AC', 'AP', 'AM', 'PA', 'RO', 'RR', 'TO') THEN 'Região Norte'
        WHEN sigla_uf IN ('AL', 'BA', 'CE', 'MA', 'PB', 'PE', 'PI', 'RN', 'SE') THEN 'Região Nordeste'
        WHEN sigla_uf IN ('DF', 'GO', 'MT', 'MS') THEN 'Região Centro-Oeste'
        WHEN sigla_uf IN ('ES', 'MG', 'RJ', 'SP') THEN 'Região Sudeste'
        WHEN sigla_uf IN ('PR', 'RS', 'SC') THEN 'Região Sul'
    END AS regiao,
    SUM(CASE WHEN tipo_veiculo = 'automovel' THEN quantidade ELSE 0 END) AS Carro,
    SUM(CASE WHEN tipo_veiculo IN ('triciculo', 'motoneta', 'quadriciclo', 'side-car', 'motocicleta') THEN quantidade ELSE 0 END) AS Motos,
    SUM(CASE WHEN tipo_veiculo IN ('caminhonete', 'utilitario') THEN quantidade ELSE 0 END) AS SUV,
    SUM(CASE WHEN tipo_veiculo = 'caminhao' THEN quantidade ELSE 0 END) AS Caminhao,
    SUM(CASE WHEN tipo_veiculo IN ('onibus', 'micro-onibus') THEN quantidade ELSE 0 END) AS Onibus,
    SUM(CASE WHEN tipo_veiculo IN ('trator rodas', 'trator esteiras', 'caminhao trator') THEN quantidade ELSE 0 END) AS Trator,
    SUM(CASE WHEN tipo_veiculo IN ('outros', 'reboque', 'chassi_plataforma', 'semi-reboque', 'bonde') THEN quantidade ELSE 0 END) AS Outros
FROM
    basedosdados.br_denatran_frota.municipio_tipo 
WHERE
    ano = 2022
GROUP BY 
    regiao
ORDER BY 
    regiao DESC;
#Questão 1.2
SELECT ano,
SUM(quantidade) AS quantidade,
FROM `basedosdados.br_denatran_frota.uf_tipo` 
GROUP BY ano;
#Questão 5.3.1
SELECT 
    CASE 
        WHEN sigla_uf IN ('AC', 'AP', 'AM', 'PA', 'RO', 'RR', 'TO') THEN 'Região Norte'
        WHEN sigla_uf IN ('AL', 'BA', 'CE', 'MA', 'PB', 'PE', 'PI', 'RN', 'SE') THEN 'Região Nordeste'
        WHEN sigla_uf IN ('DF', 'GO', 'MT', 'MS') THEN 'Região Centro-Oeste'
        WHEN sigla_uf IN ('ES', 'MG', 'RJ', 'SP') THEN 'Região Sudeste'
        WHEN sigla_uf IN ('PR', 'RS', 'SC') THEN 'Região Sul'
    END AS regiao,
    SUM(CASE WHEN tipo_veiculo = 'automovel' THEN quantidade ELSE 0 END) AS Veiculo_Passeio,
    SUM(CASE WHEN tipo_veiculo IN ( 'quadriciclo','triciclo','motoneta','motocicleta','side-car','ciclomotor') THEN quantidade ELSE 0 END) AS Motos,
    SUM(CASE WHEN tipo_veiculo IN ('camioneta','caminhao trator','caminhao','caminhonete','semi-reboque','utilitario','chassi plataforma','reboque')  THEN quantidade ELSE 0 END) AS Veiculo_Carga,
    SUM(CASE WHEN tipo_veiculo IN ('bonde','onibus','micro-onibus') THEN quantidade ELSE 0 END) AS Onibus,
    SUM(CASE WHEN tipo_veiculo IN ('trator esteira','trator rodas')  THEN quantidade ELSE 0 END) AS Trator,
    SUM(CASE WHEN tipo_veiculo = 'outros' THEN quantidade ELSE 0 END) AS Outros
FROM
    basedosdados.br_denatran_frota.municipio_tipo WHERE ano = 2022
GROUP BY 
    regiao
ORDER BY 
    regiao DESC;
#Questão 1.1
SELECT sum(quantidade) as qtd FROM `basedosdados.br_denatran_frota.uf_tipo`;
#Questão 2
SELECT id_municipio,sigla_uf,
 SUM(quantidade) AS quantidade_veiculo
FROM `basedosdados.br_denatran_frota.municipio_tipo`
GROUP BY id_municipio, sigla_uf
order by quantidade_veiculo desc;
SELECT sigla_uf,
 SUM(quantidade) AS quantidade_veiculo
FROM `basedosdados.br_denatran_frota.municipio_tipo`
GROUP BY sigla_uf
ORDER BY quantidade_veiculo;
-- não mostra o nome do estado, não é muito util
SELECT id_municipio,
   SUM(quantidade) AS total_veiculos
FROM `basedosdados.br_denatran_frota.municipio_tipo`
GROUP BY id_municipio
#Questão 3.1
SELECT DISTINCT tipo_veiculo 
FROM
    basedosdados.br_denatran_frota.municipio_tipo WHERE tipo_veiculo!='' --elimina os valores vazios
#Questão 3.2
SELECT distinct
    tipo_veiculo,
    CASE
        WHEN tipo_veiculo = 'automovel' THEN 'Veiculos de passeio'
        WHEN tipo_veiculo IN ('bonde','onibus','micro-onibus') THEN 'Onibus'
        WHEN tipo_veiculo IN ('camioneta','caminhao trator','caminhao','caminhonete','semi-reboque','utilitario','chassi plataforma','reboque') THEN 'Veiculos de carga'
        WHEN tipo_veiculo IN ('trator esteira','trator rodas') THEN 'Trator'
        WHEN tipo_veiculo IN ( 'quadriciclo','triciclo','motoneta','motocicleta','side-car','ciclomotor') THEN 'Motos'
        ELSE 'Outro'
    END AS grupo_tipo
FROM
     basedosdados.br_denatran_frota.municipio_tipo WHERE tipo_veiculo!=''
    ORDER BY grupo_tipo
#Questão 4.1
SELECT 
     CASE 
        WHEN sigla_uf IN ('AC', 'AP', 'AM', 'PA', 'RO', 'RR', 'TO') THEN 'Região Norte'
        WHEN sigla_uf IN ('AL', 'BA', 'CE', 'MA', 'PB', 'PE', 'PI', 'RN', 'SE') THEN 'Região Nordeste'
        WHEN sigla_uf IN ('DF', 'GO', 'MT', 'MS') THEN 'Região Centro-Oeste'
        WHEN sigla_uf IN ('ES', 'MG', 'RJ', 'SP') THEN 'Região Sudeste'
        WHEN sigla_uf IN ('PR', 'RS', 'SC') THEN 'Região Sul'
    END AS regiao,
    ROUND(SUM(CASE WHEN tipo_veiculo = 'automovel' THEN quantidade ELSE 0 END) / SUM(quantidade) * 100, 2) AS Percentual_Carro,
    ROUND(SUM(CASE WHEN tipo_veiculo = 'caminhao' THEN quantidade ELSE 0 END) / SUM(quantidade) * 100, 2) AS Percentual_Caminhao,
    ROUND(SUM(CASE WHEN tipo_veiculo IN ('onibus', 'micro-onibus') THEN quantidade ELSE 0 END) / SUM(quantidade) * 100, 2) AS Percentual_Onibus,
    ROUND(SUM(CASE WHEN tipo_veiculo IN ('caminhonete', 'utilitario') THEN quantidade ELSE 0 END) / SUM(quantidade) * 100, 2) AS Percentual_SUV,
    ROUND(SUM(CASE WHEN tipo_veiculo IN ('trator rodas', 'trator esteiras', 'caminhao trator') THEN quantidade ELSE 0 END) / SUM(quantidade) * 100, 2) AS Percentual_Trator,
    ROUND(SUM(CASE WHEN tipo_veiculo IN ('triciculo', 'motoneta', 'quadriciclo', 'side-car', 'motocicleta') THEN quantidade ELSE 0 END) / SUM(quantidade) * 100, 2) AS Percentual_Motos,
    ROUND(SUM(CASE WHEN tipo_veiculo IN ('outros', 'reboque', 'chassi_plataforma', 'semi-reboque', 'bonde') THEN quantidade ELSE 0 END) / SUM(quantidade) * 100, 2) AS Percentual_Outros
FROM
    basedosdados.br_denatran_frota.municipio_tipo 
GROUP BY 
    regiao
ORDER BY 
    regiao DESC;
#Questão 4.2
SELECT 
    sigla_uf,
    ROUND(SUM(CASE WHEN tipo_veiculo = 'automovel' THEN quantidade ELSE 0 END) / SUM(quantidade) * 100, 2) AS Percentual_Carro,
    ROUND(SUM(CASE WHEN tipo_veiculo = 'caminhao' THEN quantidade ELSE 0 END) / SUM(quantidade) * 100, 2) AS Percentual_Caminhao,
    ROUND(SUM(CASE WHEN tipo_veiculo IN ('onibus', 'micro-onibus') THEN quantidade ELSE 0 END) / SUM(quantidade) * 100, 2) AS Percentual_Onibus,
    ROUND(SUM(CASE WHEN tipo_veiculo IN ('caminhonete', 'utilitario') THEN quantidade ELSE 0 END) / SUM(quantidade) * 100, 2) AS Percentual_SUV,
    ROUND(SUM(CASE WHEN tipo_veiculo IN ('trator rodas', 'trator esteiras', 'caminhao trator') THEN quantidade ELSE 0 END) / SUM(quantidade) * 100, 2) AS Percentual_Trator,
    ROUND(SUM(CASE WHEN tipo_veiculo IN ('triciculo', 'motoneta', 'quadriciclo', 'side-car', 'motocicleta') THEN quantidade ELSE 0 END) / SUM(quantidade) * 100, 2) AS Percentual_Motos,
    ROUND(SUM(CASE WHEN tipo_veiculo IN ('outros', 'reboque', 'chassi_plataforma', 'semi-reboque', 'bonde') THEN quantidade ELSE 0 END) / SUM(quantidade) * 100, 2) AS Percentual_Outros
FROM
    basedosdados.br_denatran_frota.municipio_tipo 
GROUP BY 
    sigla_uf
#Questão 5.3.2
SELECT 
    CASE 
        WHEN sigla_uf IN ('AC', 'AP', 'AM', 'PA', 'RO', 'RR', 'TO') THEN 'Região Norte'
        WHEN sigla_uf IN ('AL', 'BA', 'CE', 'MA', 'PB', 'PE', 'PI', 'RN', 'SE') THEN 'Região Nordeste'
        WHEN sigla_uf IN ('DF', 'GO', 'MT', 'MS') THEN 'Região Centro-Oeste'
        WHEN sigla_uf IN ('ES', 'MG', 'RJ', 'SP') THEN 'Região Sudeste'
        WHEN sigla_uf IN ('PR', 'RS', 'SC') THEN 'Região Sul'
    END AS regiao,
    SUM(populacao) AS populacao
FROM 
    `basedosdados.br_ibge_censo_2022.populacao_grupo_idade_uf`
where grupo_idade not in ('0 a 4', '5 a 9', '10 a 14','15 a 17','15 a 19')
GROUP BY 
    regiao
ORDER BY populacao DESC
#Total 12/2021 tabela principal
SELECT SUM(total) AS total,
FROM `koru-dados-417611.AnaliseFinalDenatran.tabela-principal` 
WHERE mes = 12 AND ano = 2021
#Total uf tabela principal
SELECT SUM(total) AS total, SIGLA_UF
FROM `koru-dados-417611.AnaliseFinalDenatran.tabela-principal`
WHERE mes = 12 AND ano = 2021
GROUP BY SIGLA_UF
