<?php
$conexao = conecta();
$offset = 0;


for ($i=0; $i<=30000; $i+=100){
    $offset = $offset +100;
    echo "Offset - ".$offset;
    $json = file_get_contents("https://www.giantbomb.com/api/user_reviews/?format=json&api_key=[API_KEY]&offset=".$offset."&field_list=game,deck,description,score");

    $json_data = json_decode($json,true);

    foreach ($json_data['results'] as $resposta){
        $deck = $resposta['deck'];
        $description = $resposta['description'];
        $score = $resposta['score'];
        $game = $resposta['game'];
        $game = $game['name'];
        $description = limpa_string($description);
        $query = "INSERT INTO `teste_msr`.`reviews`(`deck`, `description`, `game`, `score`) VALUES ('$deck', '$description', '$game', $score)";
        $resultadoInsert = enviaSQL($query, $conexao);
        echo $game." - ".$deck." - ".$score;
        echo "<hr>";

    }
}

function limpa_string($string){
    
    $patterns = array('/<div>/', '/<?div>/', '/<?p>/', '/<?br?>/', '/<br?/', '/\[img?\](.*?)\[\/>]/','/classcontent/');
    $string = preg_replace( $patterns, " ", $string );
    $especiais= Array(".",",",";","!","@","#","%","¨","*","(",")","+","-","=", "§","$","|","\\",":","/","<",">","?","{","}","[","]","&","'",'"',"´","`","?",'“','”','$',"'","'","<div>","</div>","</br>");
    $string = str_replace($especiais,"",trim($string));
    $patterns2 = array('/classcontent lh16 cl pb10/', '/http?/', '/src?/', '/href?/', '/www?/' );
    $string = preg_replace( $patterns2, "", $string );
    return $string;
  }

function enviaSQL($sql_query, $conn){
    if ($conn->query($sql_query) === TRUE) {
        $return =  "Conexão Estabelecida com sucesso";
      } else {
        $return = "Erro: " . $sql_query . "<br>" . $conn->error;
      }

    return $return;
}


function conecta(){
    $servername = "servername";
    $username = "username";
    $password = "password";

    $conexao = new mysqli($servername, $username, $password);

    return $conexao;
}