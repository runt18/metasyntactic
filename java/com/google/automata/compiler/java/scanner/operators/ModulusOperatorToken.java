package com.google.automata.compiler.java.scanner.operators;

public class ModulusOperatorToken extends OperatorToken {
  public final static ModulusOperatorToken instance = new ModulusOperatorToken();

  private ModulusOperatorToken() {
    super("%");
  }
}
