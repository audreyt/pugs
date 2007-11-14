use v6-alpha;

grammar Language::Toto::Grammar;

token TOP {
    <block>+    |   { die "can't find any program blocks" }
}

token block {
    [
        <block_header>  |  { die "missing block header" }
    ]
    [
        <block_name>    |  { die "missing block name" }
    ]
    [
        <block_description>   
                        |  { die "missing block description" }
    ]
}

token block_header {
    <.next_line>*
    $<block_type> := [
        |   Process
        |   Procedure
        |   Activity
    ]
    <.spaces>
    <ident>
    <.next_line>
}

token block_name {
    <.next_line>*
    <.tab1>
    Name
    <.next_line>
    [
        |   <.tab2> 
            $<text> := [ \N+ ]
            <.next_line>
        |   <.next_line>
    ]+
}

token block_description {
    <.next_line>*
    <.tab1>
    Description
    <.next_line>
    [
        |   <.tab2> 
            $<text> := [ \N+ ]
            <.next_line>
        |   <.next_line>
    ]+
}

# utilities

token spaces {
    [ ' ' | \t ]+
}

token tab1 {
    ' '**{4}
}

token tab2 {
    |  ' '**{8}
    |  ' ' \t   # XXX
    |  \t
}

token next_line {
    <.spaces>? [ \n | $ ]
}

=begin

Syntax tree

    block
        block_header
            block_type    :=  Process | Procedure | Activity
            ident         :=  String

=end

=begin Example

Procedure   Acolhimento

    Name    
    
        Procedimento de Acolhimento
        
    Description
    
        Parte do Processo de Contratação

    New         from    Process Contratação
     
    Pending     on      Process CompraPortatil
    Pending     on      Procedure CompraTelemovel
    Pending     on      Procedure ConfiguraRede

    # Inicia e esquece  XXX   ->New    ??? talvez não exista
    # Inicia e espera   YYY   Pending->New
    
    Resolved    to      [ARCHIVE]                       -- plugin
    Reject      to      Procedure ProblemaAcolhimento
    Anomaly     to      Activity ErroAcolhimento


Process   CompraPortatil

    Name    
    
        Processo de Compra de um Portatil
        
    Description
    
        Parte do Processo de Contratação ou compra extra

    New         from    Procedure Acolhimento
    New         from    Procedure IniciaProjeto
    New         from    Procedure SolicitaCompra
    # Pending     on    -- não há dependencias externas
    Anomaly     to      Activity ErroCompraPortatil

Activity CompraPortatilEspecificar

    Parent      is      Process   CompraPortatil
    New         from    Process   CompraPortatil
    Pending     on      [FORM-PLUGIN]
    Resolved    to      Activity CompraPortatilSolicitaOrcament
    Anomaly     to      Activity ErroAutorizaPortatil
    
Activity CompraPortatilSolicitaOrcament

    Parent      is      Process   CompraPortatil
    Pending     on      [FORM-PLUGIN]
    Resolved    to      Activity CompraPortatilAutorizaCompraPortatil
    Anomaly     to      Activity ErroAutorizaPortatil
    
Activity CompraPortatilAutorizaCompraPortatil
    
    Parent      is      Process   CompraPortatil
    Pending     on      [FORM-PLUGIN]
    Resolved    to      Activity EncomendaPortatil 
    Anomaly     to      Activity ErroAutorizaPortatil

Activity EncomendaPortatil
    
    Parent      is      Process   CompraPortatil
    Pending     on      [FORM-PLUGIN]
    # Resolved -- fim do processo
    # Anomaly  -- resolvida pelo pai


=end