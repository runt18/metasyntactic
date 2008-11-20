// Copyright 2008 Google Inc. All rights reserved.

package com.google.automata.compiler.java.scanner.keywords;

public class PublicKeywordToken extends KeywordToken {
  public static final PublicKeywordToken instance = new PublicKeywordToken();

  private PublicKeywordToken() {
    super("public");
  }
}
