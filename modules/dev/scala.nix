# /qompassai/nix/modules/2/scala.nix
# ---------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{ config, lib, pkgs, ... }:
let
  cfg = config.programming.scala;
  inherit (lib) mkEnableOption mkOption types;
in {
  options.programming.scala = {
    enable = mkEnableOption "Scala development environment";
    jdk = mkOption {
      type = types.package;
      default = pkgs.graalvm-ce;
      description = "JDK package to use (default: GraalVM 21)";
    };
    version = mkOption {
      type = types.enum [ "3.6.4" "2.13.15" ];
      default = "3.6.4";
    };
  };

  config = lib.mkIf cfg.enable (let
    scalaPkg = pkgs.scala.override {
      jre = cfg.jdk;
      scalaVersion = cfg.version;
    };

    mavenSettings = pkgs.writeText "settings.xml" ''
      <settings xmlns="http://maven.apache.org/SETTINGS/2.0.0"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:schemaLocation="http://maven.apache.org/SETTINGS/2.0.0 
                https://maven.apache.org/xsd/settings-2.0.0.xsd">
        <localRepository>${config.xdg.cacheHome}/m2/repository</localRepository>
        <profiles>
          <profile>
            <id>qompass-jdk</id>
            <activation>
              <activeByDefault>true</activeByDefault>
              <jdk>${cfg.jdk.version}</jdk>
            </activation>
            <properties>
              <maven.compiler.source>${cfg.jdk.version}</maven.compiler.source>
              <maven.compiler.target>${cfg.jdk.version}</maven.compiler.target>
            </properties>
          </profile>
        </profiles>
      </settings>
    '';
  in {
    environment.systemPackages = with pkgs; [
      scalaPkg
      sbt
      metals
      maven
      cfg.jdk
    ];

    environment.variables = {
      JAVA_HOME = "${cfg.jdk}";
      MAVEN_OPTS = "-Xmx2G -Duser.home=${config.home.homeDirectory}";
    };

    home.file.".m2/settings.xml".source = mavenSettings;

    xdg.configFile."mvn2nix/mvn2nix-lock.json".text = builtins.toJSON {
      dependencies = [
        "org.scala-lang:scala3-compiler_3:3.6.4"
        "org.scala-lang:scala-library:2.13.15"
      ];
    };

    programs.bash.shellInit = ''
      export PATH="${cfg.jdk}/bin:$PATH"
      alias mvn="mvn -s ${mavenSettings}"
    '';

    home.file.".config/metals/metals.sbt".text = ''
      addSbtPlugin("org.scalameta" % "sbt-metals" % "1.0.0")
    '';
  });
}
