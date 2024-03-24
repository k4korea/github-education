# github-education

## AWS CodeSeries 

 ### 실습을 속도있게 정확히 끝내는 방법
 - Workshop 의 단어를 동일한 단어로 사용
 -  "-", "_" , " " 공간을 재확인
 - typing 보다는 Copy & Paste
 - 과정중의 Role, Project 의 이름을 temp 파일을 생성후 저장하고 확인
 - workshop studio web page 오류 : 페이지를 2~3 개 미리 뛰우고 에러가 발생하는 
    Page Close 함.  ( 이전 tab 의 Page를  Lab 1.2.3. 링크로 다시 사용 )
 - Cloud9 을 Public subnet에 배포
 - CodeCommit, Cloudformation, VPC, EC2 페이지 순서대로 켜두고 작업

 ### AWS CodeSeries debugging 
   #### codebuild BuildSpec 에러
   
     ㄱ. buildspec 파일사용 선택
          Buildspec 이름에  빈공간
        
     ㄴ. yaml, yml 사용의 확장자 확인 
     ㄷ. settings.xml 의 AWS 계정확인 
     
        # code
          <url>https://unicorns-<본인계정ID>.d.codeartifact.us-east-2.amazonaws.com/maven/unicorn-packages/</url>
          <password>${env.CODEARTIFACT_AUTH_TOKEN}</password>
        code end !
 
   #### codedeploy ec2 debugging 

   
   ㄱ. EC2 instance 연결 -> Session Manager -> bash -> ps -ef | grep codedeploy
   ㄴ. codedeploy log : less /var/log/aws/codedeploy-agent/codedeploy-agent.log
   ㄷ. 에러메시지 정리 사이트 
        i.  https://suyeoniii.tistory.com/97
        ii. https://oops4u.tistory.com/2591
   ㄹ. codedeploy 권한 문제시 
       service codedeploy-agent restart
   ㅁ. yaml file error, file not exists
       i. appspec.yml, buildspec.yml 상위 Root 경로에 위치
       ii. script/install_dependencies.sh, start_server.sh, stop_server.sh 실행권한이 있어야 함. 
            chmod +x ./script/
       iii. 

       ![image](https://github.com/k4korea/github-education/assets/30616772/731ec7e3-03b0-4cb8-b516-922680138287)


         

     
