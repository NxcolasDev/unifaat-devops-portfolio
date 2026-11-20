# Lambda AIOps

`index.js` recebe eventos de estado de alarmes do CloudWatch. Se `BEDROCK_MODEL_ID` estiver definido, consulta o modelo pelo AWS SDK; caso contrario, usa regras conservadoras. Em ambos os casos, a resposta exige revisao humana.

Para simular sem AWS:

```bash
node local-simulator.js
```

Para criar o artefato Terraform:

```bash
bash ../scripts/package-lambda.sh
```
