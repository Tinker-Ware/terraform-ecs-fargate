resource "aws_api_gateway_vpc_link" "vpc_link" {
  name        = "${var.service_name_3}-vpc-link"
  target_arns = [aws_lb.private_nlb.arn]
}


resource "aws_api_gateway_authorizer" "rest-api-auth" {
  name                   = "rest-api-auth"
  rest_api_id            = aws_api_gateway_rest_api.rest_api.id
  authorizer_uri         = aws_lambda_function.authorizer.invoke_arn
  authorizer_credentials = aws_iam_role.invocation_role.arn
}


resource "aws_iam_role" "invocation_role" {
  name = "api_gateway_auth_invocation"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "invocation_policy" {
  name = "hv-auth-lambda-policy"
  role = aws_iam_role.invocation_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${aws_lambda_function.authorizer.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role" "lambda" {
  name = "demo-lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "authorizer" {
  filename      = "hv-apigw-python-authorizer.zip"
  function_name = "hv-api-authorizer"
  role          = aws_iam_role.lambda.arn
  handler       = "hv-apigw-python-authorizer.lambda_function"
  runtime       = "python3.8"

  source_code_hash = filebase64sha256("hv-apigw-python-authorizer.zip")
}








resource "aws_api_gateway_rest_api" "rest_api" {
  name = "hv-vpc-api"
  endpoint_configuration {
    types=["REGIONAL"]
  }
  body = jsonencode({
  "swagger" : "2.0",
  "info" : {
    "version" : "2021-08-06T20:25:11Z",
    "title" : "hv-stage-vpc-api"
  },
  "basePath" : "/stage",
  "schemes" : [ "https" ],
  "paths" : {
    "/" : {
      "options" : {
        "consumes" : [ "application/json" ],
        "produces" : [ "application/json" ],
        "responses" : {
          "200" : {
            "description" : "200 response",
            "schema" : {
              "$ref" : "#/definitions/Empty"
            },
            "headers" : {
              "Access-Control-Allow-Origin" : {
                "type" : "string"
              },
              "Access-Control-Allow-Methods" : {
                "type" : "string"
              },
              "Access-Control-Allow-Headers" : {
                "type" : "string"
              }
            }
          }
        },
        "security" : [ {
          "hv-api-authorizer" : [ ]
        } ],
        "x-amazon-apigateway-integration" : {
          "responses" : {
            "default" : {
              "statusCode" : "200",
              "responseParameters" : {
                "method.response.header.Access-Control-Allow-Methods" : "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
                "method.response.header.Access-Control-Allow-Headers" : "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
                "method.response.header.Access-Control-Allow-Origin" : "'*'"
              }
            }
          },
          "requestTemplates" : {
            "application/json" : "{\"statusCode\": 200}"
          },
          "passthroughBehavior" : "when_no_match",
          "type" : "mock"
        }
      },
      "x-amazon-apigateway-any-method" : {
        "produces" : [ "application/json" ],
        "responses" : {
          "200" : {
            "description" : "200 response",
            "schema" : {
              "$ref" : "#/definitions/Empty"
            }
          }
        },
        "security" : [ {
          "hv-api-authorizer" : [ ]
        } ],
        "x-amazon-apigateway-integration" : {
          "connectionId" : aws_api_gateway_vpc_link.vpc_link.id,
          "httpMethod" : "ANY",
          "uri" : "http://${var.subdomain_3}.${var.domain}",
          "responses" : {
            "default" : {
              "statusCode" : "200"
            }
          },
          "passthroughBehavior" : "when_no_match",
          "connectionType" : "VPC_LINK",
          "type" : "http_proxy"
        }
      }
    },
    "/{proxy+}" : {
      "options" : {
        "consumes" : [ "application/json" ],
        "produces" : [ "application/json" ],
        "responses" : {
          "200" : {
            "description" : "200 response",
            "schema" : {
              "$ref" : "#/definitions/Empty"
            },
            "headers" : {
              "Access-Control-Allow-Origin" : {
                "type" : "string"
              },
              "Access-Control-Allow-Methods" : {
                "type" : "string"
              },
              "Access-Control-Allow-Headers" : {
                "type" : "string"
              }
            }
          }
        },
        "security" : [ {
          "${aws_lambda_function.authorizer.function_name}" : [ ]
        } ],
        "x-amazon-apigateway-integration" : {
          "responses" : {
            "default" : {
              "statusCode" : "200",
              "responseParameters" : {
                "method.response.header.Access-Control-Allow-Methods" : "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
                "method.response.header.Access-Control-Allow-Headers" : "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
                "method.response.header.Access-Control-Allow-Origin" : "'*'"
              }
            }
          },
          "requestTemplates" : {
            "application/json" : "{\"statusCode\": 200}"
          },
          "passthroughBehavior" : "when_no_match",
          "type" : "mock"
        }
      },
      "x-amazon-apigateway-any-method" : {
        "produces" : [ "application/json" ],
        "parameters" : [ {
          "name" : "proxy",
          "in" : "path",
          "required" : true,
          "type" : "string"
        } ],
        "responses" : { },
        "security" : [ {
          "${aws_lambda_function.authorizer.function_name}" : [ ]
        } ],
        "x-amazon-apigateway-integration" : {
          "connectionId" : aws_api_gateway_vpc_link.vpc_link.id,
          "httpMethod" : "ANY",
          "uri" : "http://${var.subdomain_3}.${var.domain}/{proxy}",
          "responses" : {
            "default" : {
              "statusCode" : "200"
            }
          },
          "requestParameters" : {
            "integration.request.path.proxy" : "method.request.path.proxy"
          },
          "passthroughBehavior" : "when_no_match",
          "connectionType" : "VPC_LINK",
          
          "cacheKeyParameters" : [ "method.request.path.proxy" ],
          "type" : "http_proxy"
        }
      }
    }
  },
  "securityDefinitions" : {
    "hv-api-authorizer" : {
      "type" : "apiKey",
      "name" : "Unused",
      "in" : "header",
      "x-amazon-apigateway-authtype" : "custom",
      "x-amazon-apigateway-authorizer" : {
        "authorizerUri" : "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:445822713320:function:hv-apigw-python-authorizer/invocations",
        "authorizerResultTtlInSeconds" : 0,
        "type" : "request"
      }
    }
  },
  "definitions" : {
    "Empty" : {
      "type" : "object",
      "title" : "Empty Schema"
    }
  },
  "x-amazon-apigateway-gateway-responses" : {
    "DEFAULT_5XX" : {
      "responseParameters" : {
        "gatewayresponse.header.Access-Control-Allow-Methods" : "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
        "gatewayresponse.header.Access-Control-Allow-Origin" : "'*'",
        "gatewayresponse.header.Access-Control-Allow-Headers" : "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
      }
    },
    "ACCESS_DENIED" : {
      "statusCode" : 403,
      "responseParameters" : {
        "gatewayresponse.header.Access-Control-Allow-Methods" : "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
        "gatewayresponse.header.Access-Control-Allow-Origin" : "'*'",
        "gatewayresponse.header.Access-Control-Allow-Headers" : "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
      },
      "responseTemplates" : {
        "application/json" : "{\"message\":$context.error.messageString}"
      }
    },
    "DEFAULT_4XX" : {
      "responseParameters" : {
        "gatewayresponse.header.Access-Control-Allow-Methods" : "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
        "gatewayresponse.header.Access-Control-Allow-Origin" : "'*'",
        "gatewayresponse.header.Access-Control-Allow-Headers" : "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
      }
    }
  }
})
  
}