// Copyright 2008 Google Inc. All rights reserved.

package org.metasyntactic.automata.compiler.java.scanner.keywords;

public class WhileKeywordToken extends KeywordToken {
  public static final WhileKeywordToken instance = new WhileKeywordToken();

  private WhileKeywordToken() {
    super("while");
  }

  protected Type getTokenType() {
    return Type.WhileKeyword;
  }
}
