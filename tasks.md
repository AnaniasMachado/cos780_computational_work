# Tasks

## 1. Modelagem Matemática

O problema que queremos resolver é o problema de transporte com as seguintes características.

- Temos $m$ centros de produções e $n$ armazéns.
- Cada centro de produção possui uma capacidade de produção $q_i$.
- Cada armazéns possui uma demanda $d_i$.
- Cada centro de produção deve possuir uma produção de no mínimo $75\%$ da sua capacidade.
- O custo de transporte do centro de produção $i$ para o armazém $j$ é denotado por $c_{i,j}$.

E os seguintes dados:

- Centros de Produção: $P = \{\text{Curitiba}, \text{Manaus}, \text{Belo Horizonte}, \text{Rio de Janeiro}, \text{Sao Paulo}\}$.
- Armazéns: $A = \{\text{Campinas}, \text{Vitória}, \text{Joinville}, \text{Porto Alegre}, \text{Joao Pessoa}, \text{Recife}\}$.
- Capacidade: $Q = \{180, 200, 140, 80, 180\}$.
- Demanda: $D = \{89, 95, 121, 101, 116, 181\}$.
- Custo de transporte: $C = \begin{bmatrix}
        4.50 & 5.09 & 4.33 & 5.96 & 1.96 & 7.30\\
        3.33 & 4.33 & 3.38 & 1.53 & 5.95 & 4.01\\
        3.02 & 2.61 & 1.61 & 4.44 & 2.36 & 4.60\\
        2.43 & 2.37 & 2.54 & 4.13 & 3.20 & 4.88\\
        6.42 & 4.83 & 3.39 & 4.40 & 7.44 & 2.92\\
      \end{bmatrix}$

Este problema pode ser modelado da seguinte maneira:

$\text{Min}_{X \in \mathbb{R}^{m \times n}} \text{tr}(C^\top X)\\
\text{s.t.}\sum_{j=1}^{n}X_{i,j} \geq 0.75Q_i, \hspace{5 pt} i = 1, ..., m\\
\hspace{16pt} \sum_{j=1}^{n}X_{i,j} \leq Q_i, \hspace{22 pt} i = 1, ..., m\\
\hspace{16pt} \sum_{i=1}^{m}X_{i,j} \geq D_j, \hspace{23 pt} j = 1, ..., n\\
\hspace{16pt} X \geq 0$

Onde a variável $X$ é tal que $X_{i, j} =$ quantidade de produto que está sendo transportada do centro de produção $i$ para o centro de distribuição $j$.

## 3. Resolvendo o problema e analisando a solução

A solução é dada por $X = \begin{bmatrix}
  19 & 0 & 0 & 0 & 116 & 0\\
  66 & 0 & 0 & 101 & 0 & 1\\
  0 & 19 & 121 & 0 & 0 & 0\\
  4 & 76 & 0 & 0 & 0 & 0\\
  0 & 0 & 0 & 0 & 0 & 180\\
\end{bmatrix}$

E o custo total ótimo é dado por $z^* = \text{trace}(C^\top X) = 1651.2$.

## 4. Análise de sensibilidade - Centros de produção

### (a) Intervalo de variação da base ótima

Produção mínima limite inferior: $y^l_1 = \{116.0, -\infty, -\infty, -\infty, -\infty\}$.
Produção mínima limite superior: $y^u_1 = \{153.0, 168.0, 140.0, 80.0, 180.0\}$.
Produção máxima limite inferior: $y^l_2 = \{135.0, 168.0, 136.0, 76.0, 148.0\}$.
Produção máxima limite superior: $y^u_2 = \{inf, inf, 158.0, 98.0, 181.0\}$.
Demanda mínima limite inferior: $y^l_3 = \{71.0, 77.0, 103.0, 83.0, 98.0, 180.0\}$.
Demanda mínima limite superior: $y^u_3 = \{121.0, 99.0, 125.0, 133.0, 135.0, 213.0\}$.

### (b) Variável dual, variação máxima permitida e ganho

Produção mínima: $w_1 = \{1.17, 0.0, 0.0, 0.0, 0.0\}$.
Produção máxima: $w_2 = \{0.0, 0.0, -0.6600000000000001, -0.8999999999999999, -1.0899999999999999\}$.
Demanda mínima: $w_3 = \{3.33, 3.27, 2.2700000000000005, 1.53, 0.79, 4.01\}$.

Encontremos agora o problema dual para determinar o ganho. Temos que o lagrangiano do problema de programação linear considerado é:

$L(X, \lambda, \mu, \nu, \Delta) = \text{tr}(C^\top X) + \sum_{i=1}^{m}\lambda_i(\sum_{j=1}^{n}X_{i,j} - 0.75Q_i) + \sum_{i=1}^{m}\mu_i(Q_i - \sum_{j=1}^{n}X_{i,j}) + \sum_{j=1}^{n}\nu_j(\sum_{i=1}^{m}X_{i,j} - D_j) - \text{tr}(\Delta^\top X)\\
= \text{tr}(C^\top X) + \sum_{i=1}^{m}\sum_{j=1}^{n}\lambda_iX_{i,j} - \sum_{i=1}^{m}0.75\lambda_iQ_i + \sum_{i=1}^{m}\mu_iQ_i - \sum_{i=1}^{m}\sum_{j=1}^{n}\mu_iX_{i,j} + \sum_{j=1}^{n}\nu_j\sum_{i=1}^{m}X_{i,j} - \sum_{j=1}^{n}\nu_jD_j - \text{tr}(\Delta^\top X)\\
= \sum_{i=1}^{m}\sum_{j=1}^{n}(C_{i,j}X_{i,j} + \lambda_iX_{i,j} - \mu_iX_{i,j} + \nu_jX_{i,j} - \Delta_{i,j}X_{i,j}) + \sum_{i=1}^{m}(\mu_iQ_i - 0.75\lambda_iQ_i) - \sum_{j=1}^{n}\nu_jD_j$

Logo, a função dual lagrangiana associada é:

$g(\lambda, \mu, \nu) = \sum_{i=1}^{m}(\mu_iQ_i - 0.75\lambda_iQ_i) - \sum_{j=1}^{n}\nu_jD_j$

E o problema dual é:

$\text{Max}_{\lambda, \mu \in \mathbb{R}^{m}, \nu \in \mathbb{R}^{n}} \sum_{i=1}^{m}(\mu_iQ_i - 0.75\lambda_iQ_i) - \sum_{j=1}^{n}\nu_jD_j\\
\text{s.t.}\sum_{i=1}^{m}\sum_{j=1}^{n}(C_{i,j}X_{i,j} + \lambda_iX_{i,j} - \mu_iX_{i,j} + \nu_jX_{i,j} - \Delta_{i,j}X_{i,j}) = 0$

Que na forma padrão é equivalente à:

$\text{Min}_{\lambda, \mu \in \mathbb{R}^{m}, \nu \in \mathbb{R}^{n}} \sum_{i=1}^{m}(0.75\lambda_iQ_i - \mu_iQ_i) + \sum_{j=1}^{n}\nu_jD_j\\
\text{s.t.}\sum_{i=1}^{m}\sum_{j=1}^{n}(C_{i,j}X_{i,j} + \lambda_iX_{i,j} - \mu_iX_{i,j} + \nu_jX_{i,j} - \Delta_{i,j}X_{i,j}) = 0$

Logo, o valor da função objetivo em termos de perturbações nas restrições de capacidade de produção é:

$\bar{z}^* = z^* + \sum_{i=1}^{m}(0.75\lambda_i(Q_i + \delta_i) - \mu_i(Q_i + \varepsilon_i))$

Onde $z^*$ é o valor ótimo da função objetivo, $\delta_i$ é a perturbação na restrição $i$ de produção mínima, e $\varepsilon_i$ é a perturbação na restrição $i$ de produção máxima.

Computando todas as opções de perturbações de somente uma restrição temos que a perturbação que gera o maior decréscimo do valor da função objetivo é na restrição de produção mínima de índice 1 gerando uma redução no valor da função objetivo de -389.609.

## 5. Análise de sensibilidade - Escolha de rota

### (a) Para cada um dos custos, verifique o intervalo de variação para que a base ótima se mantenha

Temos que os intervalos de variação de cada variável para que a base ótima se mantém são:

$C_{lower} = \begin{bmatrix}
  3.33 & 4.44 & 3.44 & 2.7 & 1.17 & 5.18\\
  2.67 & 3.27 & 2.27 & 0. & 0.79 & 2.92\\
  2.67 & 1.72 & -0.66 & 0.87 & 0.13 & 3.35\\
  1.78 & 2.02 & 1.37 & 0.63 & -0.11 & 3.11\\
  2.24 & 2.18 & 1.18 & 0.44 & -0.3 & -\infty\\
\end{bmatrix}$

$C_{upper} = \begin{bmatrix}
  5.15 & \infty & \infty & \infty & 4.19 & \infty\\
  4.39 & \infty & \infty & 4.79 & \infty & 5.26\\
  \infty & 2.96 & 2.5 & \infty & \infty & \infty\\
  2.78 & 3.02 & \infty & \infty & \infty & \infty\\
  \infty & \infty & \infty & \infty & \infty & 4.01\\
\end{bmatrix}$

### (b) Usando o valor ótimo da variável primal associada e considerando a variação máxima permitida nesse invervalo, determine o ganho com essa possı́vel alteração

Computando todas as possibilidades de produtos $C_{lower}, C_{upper}$ com $X$, temos que a melhor opção de rota para ficar livre de taxação é a rota de Rio de Janeiro para João Pessoa, que possui ganho de $4.01 * 180.0 = 721.8$.