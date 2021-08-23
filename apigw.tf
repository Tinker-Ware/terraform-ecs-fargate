resource "aws_api_gateway_vpc_link" "vpc-link" {
  name        = "${var.service_name_3}-vpc-link"
  target_arns = [aws_lb.private-nlb.arn]
}

resource "aws_api_gateway_authorizer" "hv-api-authorizer" {
  name                   = "hv-api-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.rest-api.id
  authorizer_uri         = aws_lambda_function.authorizer.invoke_arn
  authorizer_credentials = aws_iam_role.invocation-role.arn
  type                   = "REQUEST"
  identity_source = "method.request.header.origin"
  authorizer_result_ttl_in_seconds = 0
  depends_on = [
    aws_lambda_function.authorizer
  ]
}

resource "aws_api_gateway_resource" "api-proxy-resource" {
  rest_api_id = aws_api_gateway_rest_api.rest-api.id
  parent_id   = aws_api_gateway_rest_api.rest-api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "api-any-method" {
  rest_api_id   = aws_api_gateway_rest_api.rest-api.id
  resource_id   = aws_api_gateway_resource.api-proxy-resource.id
  
  http_method   = "ANY"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.hv-api-authorizer.id

  request_parameters = {
    "method.request.path.proxy" = true
  }
}
resource "aws_api_gateway_integration" "api-proxy-integration" {
  rest_api_id          = aws_api_gateway_rest_api.rest-api.id
  resource_id          = aws_api_gateway_resource.api-proxy-resource.id
  http_method          = aws_api_gateway_method.api-any-method.http_method
  integration_http_method = "ANY"
  type                 = "HTTP_PROXY"
  connection_type      = "VPC_LINK"
  connection_id = aws_api_gateway_vpc_link.vpc-link.id
  uri = "http://${var.subdomain_3}.${var.domain}/{proxy}"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy",
  }

  
  depends_on = [
    aws_api_gateway_method.api-any-method
  ]
}


resource "aws_api_gateway_method" "api-options-method" {
  rest_api_id   = aws_api_gateway_rest_api.rest-api.id
  resource_id   = aws_api_gateway_resource.api-proxy-resource.id
  
  http_method   = "OPTIONS"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.hv-api-authorizer.id
}
resource "aws_api_gateway_integration" "api-opt-proxy-integration" {
  rest_api_id          = aws_api_gateway_rest_api.rest-api.id
  resource_id          = aws_api_gateway_resource.api-proxy-resource.id
  http_method          = aws_api_gateway_method.api-options-method.http_method
  integration_http_method = "OPTIONS"
  type                 = "HTTP_PROXY"
  connection_type      = "VPC_LINK"
  connection_id = aws_api_gateway_vpc_link.vpc-link.id
  uri = "http://${var.subdomain_3}.${var.domain}/{proxy}"

  depends_on = [
    aws_api_gateway_method.api-any-method
  ]
}

resource "aws_api_gateway_rest_api" "rest-api" {
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
        "responses" : {
          "200" : {
            "description" : "200 response",
            "schema" : {
              "$ref" : "#/definitions/Empty"
            }
          }
        },
        "security" : [ {
          "${aws_lambda_function.authorizer.function_name}" : [ ]
        } ],
        "x-amazon-apigateway-integration" : {
          "connectionId" : "${aws_api_gateway_vpc_link.vpc-link.id}",
          "httpMethod" : "ANY",
          "uri" :"http://${var.subdomain_3}.${var.domain}",
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
  }
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
  depends_on = [
    aws_lambda_function.authorizer
  ]

}

resource "aws_api_gateway_stage" "api-stage" {
  deployment_id = aws_api_gateway_deployment.api-deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest-api.id
  stage_name    = "test"
}

resource "aws_api_gateway_deployment" "api-deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest-api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.rest-api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}


