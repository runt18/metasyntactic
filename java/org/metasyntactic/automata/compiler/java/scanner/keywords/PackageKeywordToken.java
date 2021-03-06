// Copyright 2008 Google Inc. All rights reserved.

package org.metasyntactic.automata.compiler.java.scanner.keywords;

public class PackageKeywordToken extends KeywordToken {
  public static final PackageKeywordToken instance = new PackageKeywordToken();

  private PackageKeywordToken() {
    super("package");
  }

  protected Type getTokenType() {
    return Type.PackageKeyword;
  }
}
