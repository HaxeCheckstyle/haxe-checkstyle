# Checkstyle for Haxe

Automated code analysis tool ideal for projects that want to enforce coding conventions.

Code conventions improve readability, allowing team members to understand new code easily.

Please note that this project was originally created by [@mcheshkov](https://github.com/mcheshkov) called [haxelint](https://github.com/mcheshkov/haxelint). So full credit to him.

I have customized and made it flexible with additional checks and configurations.

### Installation ###

```haxe
haxelib install checkstyle
```

### Configuration ###

```json
{
  "checks": [
    {
      "type": "ArrayInstantiation",
      "props": {
        "severity": "ERROR"
      }
    },
    {
      "type": "BlockFormat",
      "props": {
        "severity": "ERROR"
      }
    },
    {
      "type": "EmptyLines",
      "props": {
        "severity": "INFO",
        "maxConsecutiveEmptyLines": 1
      }
    },
    {
      "type": "ERegInstantiation",
      "props": {
        "severity": "ERROR"
      }
    },
    {
      "type": "HexadecimalLiterals",
      "props": {
        "severity": "INFO"
      }
    },
    {
      "type": "IndentationCharacter",
      "props": {
        "severity": "INFO",
        "character": "tab"
      }
    },
    {
      "type": "LineLength",
      "props": {
        "severity": "ERROR",
        "maxCharacters": 120
      }
    },
    {
      "type": "MethodLength",
      "props": {
        "severity": "ERROR",
        "maxFunctionLines": 50
      }
    },
    {
      "type": "Naming",
      "props": {
        "severity": "ERROR",
        "privateUnderscorePrefix": false
      }
    },
    {
      "type": "Override",
      "props": {
        "severity": "ERROR"
      }
    },
    {
      "type": "PublicPrivate",
      "props": {
        "severity": "INFO"
      }
    },
    {
      "type": "Return",
      "props": {
        "severity": "INFO"
      }
    },
    {
      "type": "Spacing",
      "props": {
        "severity": "INFO",
        "spaceIfCondition": true,
        "spaceAroundBinop": true,
        "spaceAroundBinop": true
      }
    },
    {
      "type": "TabForAligning",
      "props": {
        "severity": "INFO"
      }
    },
    {
      "type": "TODOComment",
      "props": {
        "severity": "INFO"
      }
    },
    {
      "type": "TrailingWhitespace",
      "props": {
        "severity": "INFO"
      }
    },
    {
      "type": "VariableInitialisation",
      "props": {
        "severity": "ERROR"
      }
    }
  ]
}
```

### Reference ###

http://haxe.org/manual/class-field-visibility.html

http://adireddy.github.io/haxe/haxe-access-modifiers-return-types/

### Issues ###

Found any bug? Please create a new [issue](https://github.com/adireddy/haxe-checkstyle/issues/new).
